# Make built assets (Tailwind output) available to Propshaft in all environments.
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
