import "@hotwired/turbo-rails"
import { init as initThemeLab } from "theme_lab"
import { init as initUserMenu } from "user_menu"
import { init as initQuoteClipboard } from "quote_clipboard"

const initAll = () => {
  initThemeLab()
  initUserMenu()
  initQuoteClipboard()
}

initAll()
document.addEventListener("turbo:load", initAll)
