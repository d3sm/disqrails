import { showToast } from "toast"

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
