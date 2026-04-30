<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'

const router = useRouter()

const books = ref([])
const loading = ref(false)
const actionLoadingId = ref(null)
const message = ref('')

const isLoggedIn = computed(() => !!localStorage.getItem('token'))

const loadBooks = async () => {
  try {
    loading.value = true
    message.value = ''

    const response = await http.get('/books')
    books.value = response.data
  } catch (error) {
    console.error('Load books failed:', error)
    message.value = error.response?.data?.message || error.message || '書籍資料載入失敗'
  } finally {
    loading.value = false
  }
}

const borrowBook = async (inventoryId) => {
  if (!isLoggedIn.value) {
    message.value = '請先登入後再借閱書籍'
    router.push('/login')
    return
  }

  try {
    actionLoadingId.value = inventoryId
    message.value = ''

    await http.post(`/borrows/${inventoryId}`)

    message.value = '借閱成功'
    await loadBooks()
  } catch (error) {
    console.error('Borrow failed:', error)

    if (error.response?.status === 401 || error.response?.status === 403) {
      message.value = '登入狀態已失效，請重新登入'
      localStorage.removeItem('token')
      localStorage.removeItem('userName')
      window.dispatchEvent(new Event('auth-changed'))
      router.push('/login')
      return
    }

    message.value = error.response?.data?.message || '借閱失敗'
  } finally {
    actionLoadingId.value = null
  }
}

const returnBook = async (inventoryId) => {
  if (!isLoggedIn.value) {
    message.value = '請先登入後再還書'
    router.push('/login')
    return
  }

  try {
    actionLoadingId.value = inventoryId
    message.value = ''

    await http.post(`/borrows/${inventoryId}/return`)

    message.value = '還書成功'
    await loadBooks()
  } catch (error) {
    console.error('Return failed:', error)

    if (error.response?.status === 401 || error.response?.status === 403) {
      message.value = '登入狀態已失效，請重新登入'
      localStorage.removeItem('token')
      localStorage.removeItem('userName')
      window.dispatchEvent(new Event('auth-changed'))
      router.push('/login')
      return
    }

    message.value = error.response?.data?.message || '還書失敗'
  } finally {
    actionLoadingId.value = null
  }
}

onMounted(loadBooks)
</script>

<template>
  <section class="page-card">
    <div class="page-header">
      <div>
        <h1>書籍列表</h1>
        <p class="subtitle">查看目前館藏與借閱狀態，登入後可借閱或歸還書籍。</p>
      </div>

      <button class="secondary-button" @click="loadBooks">重新整理</button>
    </div>

    <p v-if="loading" class="loading">載入中...</p>
    <p v-if="message" class="message">{{ message }}</p>

    <div class="book-grid">
      <article v-for="book in books" :key="book.inventoryId" class="book-card">
        <div class="book-top">
          <h2>{{ book.name }}</h2>

          <span
            class="status-badge"
            :class="book.status === 'AVAILABLE' ? 'available' : 'borrowed'"
          >
            {{ book.status }}
          </span>
        </div>

        <p><strong>作者：</strong>{{ book.author }}</p>
        <p><strong>ISBN：</strong>{{ book.isbn }}</p>
        <p><strong>庫存編號：</strong>{{ book.inventoryId }}</p>
        <p class="intro">{{ book.introduction }}</p>

        <div class="actions">
          <button
            v-if="book.status === 'AVAILABLE'"
            :disabled="actionLoadingId === book.inventoryId"
            @click="borrowBook(book.inventoryId)"
          >
            {{ actionLoadingId === book.inventoryId ? '處理中...' : '借閱' }}
          </button>

          <button
            v-else-if="book.status === 'BORROWED'"
            class="return-button"
            :disabled="actionLoadingId === book.inventoryId"
            @click="returnBook(book.inventoryId)"
          >
            {{ actionLoadingId === book.inventoryId ? '處理中...' : '還書' }}
          </button>

          <button v-else disabled>暫不可借</button>
        </div>
      </article>
    </div>
  </section>
</template>
