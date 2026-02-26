import "@hotwired/turbo-rails"
import { init as initThemeLab } from "theme_lab"
import { init as initUserMenu } from "user_menu"
import { init as initQuoteClipboard } from "quote_clipboard"
import { init as initSidebarToggle } from "sidebar_toggle"

const initAll = () => {
  initThemeLab()
  initUserMenu()
  initQuoteClipboard()
  initSidebarToggle()
}

initAll()
document.addEventListener("turbo:load", initAll)
