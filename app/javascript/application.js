import "@hotwired/turbo-rails"
import { init as initThemeLab } from "theme_lab"
import { init as initUserMenu } from "user_menu"
import { init as initQuoteClipboard } from "quote_clipboard"
import { init as initSidebarToggle } from "sidebar_toggle"
import { showToast } from "toast"

const showFlashToasts = () => {
  document.querySelectorAll("[data-toast]").forEach((el) => {
    showToast(el.dataset.toast)
    el.remove()
  })
}

const initAll = () => {
  initThemeLab()
  initUserMenu()
  initQuoteClipboard()
  initSidebarToggle()
  showFlashToasts()
}

initAll()
document.addEventListener("turbo:load", initAll)
