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

export function init() {
  const grid = document.getElementById("theme-grid")
  const applyBtn = document.getElementById("theme-apply")
  const resetBtn = document.getElementById("theme-reset")
  const status = document.getElementById("theme-status")
  const toggleBtn = document.getElementById("theme-toggle")
  const panel = document.getElementById("theme-lab-panel")
  if (!grid || !applyBtn || !resetBtn || !status || !toggleBtn || !panel) return

  const root = document.documentElement
  const inputByKey = {}

  const buildThemeInputs = () => {
    if (grid.children.length > 0) return
    themeConfig.forEach((item) => {
      const wrap = document.createElement("label")
      wrap.className = "theme-field block"

      const caption = document.createElement("span")
      caption.className = "inline-block mb-0.5 text-muted text-sm"
      caption.textContent = item.label
      wrap.appendChild(caption)

      const input = document.createElement("input")
      input.type = "text"
      input.value = item.default
      input.placeholder = "#RRGGBB"
      input.dataset.themeVar = item.key
      wrap.appendChild(input)

      inputByKey[item.key] = input
      grid.appendChild(wrap)
    })
  }

  const readThemeInputs = () => {
    const vars = {}
    Object.entries(inputByKey).forEach(([key, input]) => {
      const value = normalizeColor(input.value)
      if (value) vars[key] = value
    })
    return vars
  }

  const fillThemeInputs = (vars) => {
    themeConfig.forEach((item) => {
      const input = inputByKey[item.key]
      if (!input) return
      input.value = vars[item.key] || item.default
    })
  }

  const applyVars = (vars) => {
    themeVarNames.forEach((name) => root.style.removeProperty(name))
    Object.entries(vars).forEach(([name, value]) => {
      if (themeVarNames.includes(name) && normalizeColor(value)) {
        root.style.setProperty(name, value)
      }
    })
  }

  buildThemeInputs()
  const savedRaw = localStorage.getItem(STORAGE_KEY)
  if (savedRaw) {
    try {
      const saved = JSON.parse(savedRaw)
      if (saved && typeof saved === "object") {
        fillThemeInputs(saved)
        applyVars(saved)
        status.textContent = "Loaded saved theme."
      }
    } catch (_) {
      localStorage.removeItem(STORAGE_KEY)
    }
  } else {
    fillThemeInputs({})
  }

  applyBtn.addEventListener("click", () => {
    const parsed = readThemeInputs()
    if (Object.keys(parsed).length === 0) {
      status.textContent = "Add valid hex values like #89b4fa."
      return
    }
    applyVars(parsed)
    localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed))
    status.textContent = `Applied ${Object.keys(parsed).length} theme variables.`
  })

  resetBtn.addEventListener("click", () => {
    const defaults = {}
    themeConfig.forEach((item) => { defaults[item.key] = item.default })
    fillThemeInputs(defaults)
    applyVars(defaults)
    localStorage.setItem(STORAGE_KEY, JSON.stringify(defaults))
    status.textContent = "Theme reset to Catppuccin."
  })

  toggleBtn.addEventListener("click", () => {
    const isHidden = panel.hasAttribute("hidden")
    if (isHidden) {
      panel.removeAttribute("hidden")
      toggleBtn.setAttribute("aria-expanded", "true")
    } else {
      panel.setAttribute("hidden", "")
      toggleBtn.setAttribute("aria-expanded", "false")
    }
  })
}
