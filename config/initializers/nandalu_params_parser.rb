class NandaluParamsParser
  def initialize app
    @app = app
  end
  def call env
    @app.call(change_path(env))
  end
  def change_path env
    m = %r{^/service/(?<user_id>\w+)(?<service_path>/?.*)$}.match(env['PATH_INFO'])
    if m
      env.merge('PATH_INFO' => '/service', 
                user_id: m['user_id'], service_path: m['service_path'])
    else
      env
    end
  end
end # class NandaluParamsParser
