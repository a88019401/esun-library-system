import { createRouter, createWebHistory } from 'vue-router'
import BookListView from '../views/BookListView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/books',
    },
    {
      path: '/books',
      name: 'books',
      component: BookListView,
    },
  ],
})

export default router