import "@hotwired/turbo-rails"

const escapeHtml = (value) => {
  const div = document.createElement("div")
  div.textContent = value ?? ""
  return div.innerHTML
}

const buildPostItemHtml = (post) => {
  const rank = post.rank ? `<span>rank #${escapeHtml(String(post.rank))} on hn</span>` : ""
  const domain = post.url ? `<span class="post-domain">${escapeHtml(post.url)}</span>` : ""
  const sourceBadge = post.source === "hacker_news" ? `<span class="source-badge">hn</span>` : ""
  return `
    <li class="post-item">
      <a class="post-title" href="${escapeHtml(post.path)}">${escapeHtml(post.title)}</a>
      ${sourceBadge}
      ${domain}
      <div class="post-meta">
        <span>${escapeHtml(post.score)}</span>
        <span>by ${escapeHtml(post.author)}</span>
        <span>${escapeHtml(post.comments)}</span>
        ${rank}
        <span>posted ${escapeHtml(post.created_ago)} ago</span>
      </div>
    </li>
  `
}

const setupInfinitePosts = () => {
  const postList = document.getElementById("post-list")
  const sentinel = document.getElementById("posts-sentinel")
  const loadMoreButton = document.getElementById("posts-load-more")
  if (!postList || !sentinel) return
  if (postList.dataset.infiniteInit === "1") return
  postList.dataset.infiniteInit = "1"

  let loading = false
  let nextPage = Number(postList.dataset.nextPage || 0) || null
  const fetchUrl = postList.dataset.fetchUrl || "/posts.json"

  const updatePaginationVisibility = () => {
    if (!loadMoreButton) return
    loadMoreButton.hidden = !nextPage
  }

  if (!nextPage) {
    updatePaginationVisibility()
    sentinel.remove()
    return
  }
  updatePaginationVisibility()

  const fetchNextPage = async () => {
    if (loading || !nextPage) return
    loading = true
    sentinel.textContent = "Loading more..."
    if (loadMoreButton) loadMoreButton.disabled = true

    try {
      const connector = fetchUrl.includes("?") ? "&" : "?"
      const res = await fetch(`${fetchUrl}${connector}page=${nextPage}`, {
        headers: { Accept: "application/json" }
      })
      if (!res.ok) throw new Error(`posts-fetch-failed:${res.status}`)

      const data = await res.json()
      const posts = Array.isArray(data.posts) ? data.posts : []
      posts.forEach((post) => {
        postList.insertAdjacentHTML("beforeend", buildPostItemHtml(post))
      })

      nextPage = data.next_page || null
      postList.dataset.nextPage = nextPage || ""
      updatePaginationVisibility()
      sentinel.textContent = ""
      if (!nextPage) sentinel.remove()
    } catch (_) {
      sentinel.textContent = "Could not load more posts. Tap Load 20 more to retry."
    } finally {
      loading = false
      if (loadMoreButton) loadMoreButton.disabled = false
    }

    if (nextPage && sentinel.isConnected && sentinel.getBoundingClientRect().top <= window.innerHeight + 400) {
      fetchNextPage()
    }
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) fetchNextPage()
    })
  }, { rootMargin: "400px 0px" })

  observer.observe(sentinel)
  loadMoreButton?.addEventListener("click", fetchNextPage)
}

document.addEventListener("turbo:load", setupInfinitePosts)
