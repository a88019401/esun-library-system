<template>
  <div class="app">
    <header class="navbar">
      <RouterLink class="brand" to="/books">
        ESUN Library
      </RouterLink>

      <nav class="nav-links">
        <RouterLink to="/books">書籍列表</RouterLink>
      </nav>
    </header>

    <main class="main">
      <RouterView />
    </main>
  </div>
</template>