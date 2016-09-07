local utils = require "kong.tools.utils"
local Errors = require "kong.dao.errors"

local function generate_if_missing(v, t, column)
  if not v or utils.strip(v) == "" then
    return true, nil, { [column] = utils.random_string()}
  end
  return true
end

local function check_mandatory_scope(v, t)
  if v and not t.scopes then
    return false, "To set a mandatory scope you also need to create available scopes"
  end
  return true
end

return {
  no_consumer = true,
  fields = {
    scopes = { required = false, type = "array" },
    mandatory_scope = { required = true, type = "boolean", default = false, func = check_mandatory_scope },
    provision_key = { required = false, unique = true, type = "string", func = generate_if_missing },
    token_expiration = { required = true, type = "number", default = 7200 },
    enable_authorization_code = { required = true, type = "boolean", default = false },
    enable_implicit_grant = { required = true, type = "boolean", default = false },
    enable_client_credentials = { required = true, type = "boolean", default = false },
    enable_password_grant = { required = true, type = "boolean", default = false },
    hide_credentials = { type = "boolean", default = false },
    accept_http_if_already_terminated = { required = false, type = "boolean", default = false }
  },
  self_check = function(schema, plugin_t, dao, is_update)
    if not plugin_t.enable_authorization_code and not plugin_t.enable_implicit_grant
       and not plugin_t.enable_client_credentials and not plugin_t.enable_password_grant then
       return false, Errors.schema "You need to enable at least one OAuth flow"
    end
    return true
  end
}
