// Use event delegation so it survives Turbo page replacements
let bound = false

export function init() {
  if (bound) return
  bound = true

  document.addEventListener("click", (e) => {
    const trigger = e.target.closest("#user-menu-trigger")
    if (trigger) {
      e.stopPropagation()
      const menu = trigger.closest("#user-menu")
      if (!menu) return
      const isOpen = menu.hasAttribute("data-open")
      if (isOpen) {
        close(menu, trigger)
      } else {
        menu.setAttribute("data-open", "")
        trigger.setAttribute("aria-expanded", "true")
      }
      return
    }

    // Theme toggle lives inside the menu — dismiss menu when clicked
    if (e.target.closest("#theme-toggle")) {
      const openMenu = document.querySelector("#user-menu[data-open]")
      if (openMenu) {
        close(openMenu, openMenu.querySelector("#user-menu-trigger"))
      }
      return
    }

    // Click outside — close any open menu
    const openMenu = document.querySelector("#user-menu[data-open]")
    if (openMenu && !openMenu.contains(e.target)) {
      close(openMenu, openMenu.querySelector("#user-menu-trigger"))
    }
  })

  document.addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return
    const openMenu = document.querySelector("#user-menu[data-open]")
    if (openMenu) {
      close(openMenu, openMenu.querySelector("#user-menu-trigger"))
    }
  })
}

function close(menu, trigger) {
  menu.removeAttribute("data-open")
  if (trigger) trigger.setAttribute("aria-expanded", "false")
}
