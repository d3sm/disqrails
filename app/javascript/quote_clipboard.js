const showToast = (message) => {
  let container = document.getElementById("toast-container")
  if (!container) {
    container = document.createElement("div")
    container.id = "toast-container"
    container.className = "fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex flex-col items-center gap-2 pointer-events-none"
    document.body.appendChild(container)
  }

  const toast = document.createElement("div")
  toast.className = "pointer-events-auto px-4 py-2.5 rounded-btn bg-[var(--text)] text-[var(--bg)] text-base shadow-lg transition-opacity duration-300"
  toast.textContent = message
  container.appendChild(toast)

  setTimeout(() => {
    toast.style.opacity = "0"
    setTimeout(() => toast.remove(), 300)
  }, 2000)
}

const handleQuoteClick = async (event) => {
  const btn = event.target.closest("[data-quote-text]")
  if (!btn) return

  const text = btn.dataset.quoteText
  const quoted = text
    .split("\n")
    .map((line) => `> ${line}`)
    .join("\n")

  try {
    await navigator.clipboard.writeText(quoted)
    showToast("Quote copied to clipboard")
  } catch {
    showToast("Could not copy to clipboard")
  }
}

export const init = () => {
  document.removeEventListener("click", handleQuoteClick)
  document.addEventListener("click", handleQuoteClick)
}
