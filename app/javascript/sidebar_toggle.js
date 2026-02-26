const SIDEBAR_STORAGE_KEY = "disqrails:sidebar-collapsed"

let listenersBound = false

const sidebarElement = () => document.getElementById("tags-sidebar")

const applySidebarState = (collapsed) => {
  const sidebar = sidebarElement()
  if (!sidebar) return

  sidebar.dataset.collapsed = collapsed ? "true" : "false"
}

const restoreSidebarState = () => {
  const collapsed = window.localStorage.getItem(SIDEBAR_STORAGE_KEY) === "1"
  applySidebarState(collapsed)
}

const toggleSidebar = () => {
  const sidebar = sidebarElement()
  if (!sidebar) return

  const nextCollapsed = sidebar.dataset.collapsed !== "true"
  applySidebarState(nextCollapsed)
  window.localStorage.setItem(SIDEBAR_STORAGE_KEY, nextCollapsed ? "1" : "0")
}

const handleDocumentClick = (event) => {
  if (!event.target.closest("[data-sidebar-toggle]")) return
  toggleSidebar()
}

export const init = () => {
  restoreSidebarState()

  if (listenersBound) return

  listenersBound = true
  document.addEventListener("click", handleDocumentClick)
}
