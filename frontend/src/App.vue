<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const token = ref(localStorage.getItem('token'))
const userName = ref(localStorage.getItem('userName'))

const syncAuthState = () => {
  token.value = localStorage.getItem('token')
  userName.value = localStorage.getItem('userName')
}

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('userName')
  syncAuthState()
  router.push('/login')
}

onMounted(() => {
  window.addEventListener('auth-changed', syncAuthState)
})

onUnmounted(() => {
  window.removeEventListener('auth-changed', syncAuthState)
})
</script>

<template>
  <div class="app">
    <header class="navbar">
      <RouterLink class="brand" to="/books">
        ESUN Library
      </RouterLink>

      <nav class="nav-links">
        <RouterLink to="/books">書籍列表</RouterLink>

        <RouterLink v-if="!token" to="/login">登入</RouterLink>
        <RouterLink v-if="!token" to="/register">註冊</RouterLink>

        <span v-if="token" class="user-name">
          您好，{{ userName }}
        </span>

        <button v-if="token" class="logout-button" @click="logout">
          登出
        </button>
      </nav>
    </header>

    <main class="main">
      <RouterView />
    </main>
  </div>
</template>