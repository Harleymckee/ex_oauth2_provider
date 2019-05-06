Logger.configure(level: :warn)

ExUnit.start()

# Ensure that symlink to custom ecto priv directory exists
source = ExOauth2Provider.Test.Repo.config()[:priv]
target = Application.app_dir(:ex_oauth2_provider, source)
File.rm_rf(target)
File.mkdir_p(target)
File.rmdir(target)
:ok = :file.make_symlink(Path.expand(source), target)

# Set up database
Mix.shell.cmd("rm test/support/priv/migrations/*_create_oauth_tables.exs")
opts = if System.get_env("UUID"), do: ~w(--binary-id), else: ~w()
Mix.Task.run("ex_oauth2_provider.gen.migration", ~w(-r ExOauth2Provider.Test.Repo) ++ opts)
Mix.Task.run("ecto.drop", ~w(--quiet -r ExOauth2Provider.Test.Repo))
Mix.Task.run("ecto.create", ~w(--quiet -r ExOauth2Provider.Test.Repo))
Mix.Task.run("ecto.migrate", ~w(-r ExOauth2Provider.Test.Repo))

{:ok, _pid} = ExOauth2Provider.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(ExOauth2Provider.Test.Repo, :manual)
