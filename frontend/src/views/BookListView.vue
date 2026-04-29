<script setup>
import { onMounted, ref } from 'vue'
import http from '../api/http'

const books = ref([])
const loading = ref(false)
const message = ref('')

const loadBooks = async () => {
  try {
    loading.value = true
    message.value = ''

    const response = await http.get('/books')
    books.value = response.data
  } catch (error) {
    console.error('Load books failed:', error)
    console.error('Response:', error.response)
    console.error('Request URL:', error.config?.baseURL, error.config?.url)

    message.value =
      error.response?.data?.message ||
      error.message ||
      '書籍資料載入失敗'
  } finally {
    loading.value = false
  }
}

onMounted(loadBooks)
</script>

<template>
  <section class="page-card">
    <div class="page-header">
      <div>
        <h1>書籍列表</h1>
        <p class="subtitle">查看目前館藏與借閱狀態。</p>
      </div>

      <button class="secondary-button" @click="loadBooks">
        重新整理
      </button>
    </div>

    <p v-if="loading" class="loading">載入中...</p>
    <p v-if="message" class="message">{{ message }}</p>

    <div class="book-grid">
      <article
        v-for="book in books"
        :key="book.inventoryId"
        class="book-card"
      >
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
      </article>
    </div>
  </section>
</template>