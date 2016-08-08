if !AppConfig.has_key?(:backend_proxy_url)
  AppConfig[:backend_public_proxy_url] = AppConfig[:backend_url]
end