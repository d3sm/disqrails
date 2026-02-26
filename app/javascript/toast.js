let container = null

const getContainer = () => {
  if (container && document.body.contains(container)) return container

  container = document.createElement("div")
  container.id = "toast-container"
  container.className = "fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex flex-col items-center gap-2 pointer-events-none"
  document.body.appendChild(container)
  return container
}

export const showToast = (message, { duration = 2000 } = {}) => {
  const el = document.createElement("div")
  el.className = "pointer-events-auto px-4 py-2.5 rounded-btn bg-[var(--text)] text-[var(--bg)] text-base shadow-lg transition-opacity duration-300"
  el.textContent = message
  getContainer().appendChild(el)

  setTimeout(() => {
    el.style.opacity = "0"
    setTimeout(() => el.remove(), 300)
  }, duration)
}
