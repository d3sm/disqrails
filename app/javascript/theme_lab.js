const STORAGE_KEY = "disqrails:vim-theme-vars:v1"

const themeConfig = [
  { key: "--bg", label: "Background", default: "#1e1e2e" },
  { key: "--surface", label: "Surface", default: "#181825" },
  { key: "--surface-2", label: "Surface 2", default: "#313244" },
  { key: "--line", label: "Line", default: "#45475a" },
  { key: "--text", label: "Text", default: "#cdd6f4" },
  { key: "--muted", label: "Muted", default: "#a6adc8" },
  { key: "--accent", label: "Accent", default: "#89b4fa" },
  { key: "--danger-bg", label: "Danger BG", default: "#3a1d2e" },
  { key: "--danger-line", label: "Danger Line", default: "#f38ba8" },
  { key: "--danger-text", label: "Danger Text", default: "#f38ba8" }
]

const themeVarNames = themeConfig.map((x) => x.key)

const normalizeColor = (value) => {
  if (!value) return null
  const v = String(value).trim().replace(/^["']|["']$/g, "")
  if (/^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(v)) return v
  return null
}

const catppuccinDefaults = () => {
  const vars = {}
  themeConfig.forEach((item) => { vars[item.key] = item.default })
  return vars
}

const applyVars = (vars) => {
  const root = document.documentElement
  themeVarNames.forEach((name) => root.style.removeProperty(name))
  Object.entries(vars).forEach(([name, value]) => {
    if (themeVarNames.includes(name) && normalizeColor(value)) {
      root.style.setProperty(name, value)
    }
  })
}

// Apply saved or default theme immediately (before full init)
const applySavedTheme = () => {
  const raw = localStorage.getItem(STORAGE_KEY)
  if (raw) {
    try {
      const saved = JSON.parse(raw)
      if (saved && typeof saved === "object") {
        applyVars(saved)
        return saved
      }
    } catch (_) {
      localStorage.removeItem(STORAGE_KEY)
    }
  }
  // Fresh user — apply Catppuccin defaults and persist
  const defaults = catppuccinDefaults()
  applyVars(defaults)
  localStorage.setItem(STORAGE_KEY, JSON.stringify(defaults))
  return defaults
}

// Apply theme vars as early as possible
let currentVars = applySavedTheme()

let bound = false

export function init() {
  // Re-apply theme vars on every Turbo navigation (new DOM, inline styles lost)
  applyVars(currentVars)

  const grid = document.getElementById("theme-grid")
  const applyBtn = document.getElementById("theme-apply")
  const resetBtn = document.getElementById("theme-reset")
  const status = document.getElementById("theme-status")
  const toggleBtn = document.getElementById("theme-toggle")
  const panel = document.getElementById("theme-lab-panel")
  if (!grid || !applyBtn || !resetBtn || !status || !toggleBtn || !panel) return

  const inputByKey = {}

  // Build inputs fresh each time (Turbo replaces the DOM)
  grid.innerHTML = ""
  themeConfig.forEach((item) => {
    const wrap = document.createElement("label")
    wrap.className = "theme-field block"

    const caption = document.createElement("span")
    caption.className = "inline-block mb-0.5 text-muted text-sm"
    caption.textContent = item.label
    wrap.appendChild(caption)

    const input = document.createElement("input")
    input.type = "text"
    input.value = currentVars[item.key] || item.default
    input.placeholder = "#RRGGBB"
    input.dataset.themeVar = item.key
    wrap.appendChild(input)

    inputByKey[item.key] = input
    grid.appendChild(wrap)
  })

  const readThemeInputs = () => {
    const vars = {}
    Object.entries(inputByKey).forEach(([key, input]) => {
      const value = normalizeColor(input.value)
      if (value) vars[key] = value
    })
    return vars
  }

  // Use delegation for buttons to avoid duplicate listeners
  if (!bound) {
    bound = true

    document.addEventListener("click", (e) => {
      if (e.target.closest("#theme-apply")) {
        const grid = document.getElementById("theme-grid")
        const status = document.getElementById("theme-status")
        if (!grid || !status) return

        const inputs = grid.querySelectorAll("input[data-theme-var]")
        const parsed = {}
        inputs.forEach((input) => {
          const value = normalizeColor(input.value)
          if (value) parsed[input.dataset.themeVar] = value
        })

        if (Object.keys(parsed).length === 0) {
          status.textContent = "Add valid hex values like #89b4fa."
          return
        }
        applyVars(parsed)
        currentVars = parsed
        localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed))
        status.textContent = `Applied ${Object.keys(parsed).length} theme variables.`
        return
      }

      if (e.target.closest("#theme-reset")) {
        const defaults = catppuccinDefaults()
        applyVars(defaults)
        currentVars = defaults
        localStorage.setItem(STORAGE_KEY, JSON.stringify(defaults))

        const grid = document.getElementById("theme-grid")
        const status = document.getElementById("theme-status")
        if (grid) {
          grid.querySelectorAll("input[data-theme-var]").forEach((input) => {
            input.value = defaults[input.dataset.themeVar] || ""
          })
        }
        if (status) status.textContent = "Theme reset to Catppuccin."
        return
      }

      if (e.target.closest("#theme-toggle")) {
        const panel = document.getElementById("theme-lab-panel")
        const toggleBtn = e.target.closest("#theme-toggle")
        if (!panel) return
        const isHidden = panel.hasAttribute("hidden")
        if (isHidden) {
          panel.removeAttribute("hidden")
          if (toggleBtn) toggleBtn.setAttribute("aria-expanded", "true")
        } else {
          panel.setAttribute("hidden", "")
          if (toggleBtn) toggleBtn.setAttribute("aria-expanded", "false")
        }
      }
    })
  }
}
