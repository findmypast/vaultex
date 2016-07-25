defmodule Vaultex.Repo do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Ecto.Repo

      {otp_app, adapter, pool, config} = Ecto.Repo.Supervisor.parse_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config
      @pool pool
      @query_cache config[:query_cache] || __MODULE__
      @before_compile adapter

      require Logger
      @log_level config[:log_level] || :debug

      def config do
        Ecto.Repo.Supervisor.config(__MODULE__, @otp_app, [])
      end

      def start_link(opts) do
        password = get_password opts[:password]
        Ecto.Repo.Supervisor.start_link(__MODULE__, @otp_app, @adapter, Keyword.put(opts, :password, password))
      end

      def start_link([]) do
        Ecto.Repo.Supervisor.start_link(__MODULE__, @otp_app, @adapter, [])
      end

      defp get_password({ path, auth_method, credentials }) do
        Vaultex.Client.read(path, auth_method, credentials)
      end

      defp get_password(password) do
        password
      end

      def stop(pid, timeout \\ 5000) do
        @adapter.stop(__MODULE__, pid, timeout)
      end

      def transaction(opts \\ [], fun) when is_list(opts) do
        @adapter.transaction(__MODULE__, opts, fun)
      end

      @spec rollback(term) :: no_return
      def rollback(value) do
        @adapter.rollback(__MODULE__, value)
      end

      def all(queryable, opts \\ []) do
        Ecto.Repo.Queryable.all(__MODULE__, @adapter, queryable, opts)
      end

      def get(queryable, id, opts \\ []) do
        Ecto.Repo.Queryable.get(__MODULE__, @adapter, queryable, id, opts)
      end

      def get!(queryable, id, opts \\ []) do
        Ecto.Repo.Queryable.get!(__MODULE__, @adapter, queryable, id, opts)
      end

      def get_by(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.get_by(__MODULE__, unquote(adapter), queryable, clauses, opts)
      end

      def get_by!(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.get_by!(__MODULE__, unquote(adapter), queryable, clauses, opts)
      end

      def one(queryable, opts \\ []) do
        Ecto.Repo.Queryable.one(__MODULE__, @adapter, queryable, opts)
      end

      def one!(queryable, opts \\ []) do
        Ecto.Repo.Queryable.one!(__MODULE__, @adapter, queryable, opts)
      end

      def update_all(queryable, updates, opts \\ []) do
        Ecto.Repo.Queryable.update_all(__MODULE__, @adapter, queryable, updates, opts)
      end

      def delete_all(queryable, opts \\ []) do
        Ecto.Repo.Queryable.delete_all(__MODULE__, @adapter, queryable, opts)
      end

      def insert(model, opts \\ []) do
        Ecto.Repo.Schema.insert(__MODULE__, @adapter, model, opts)
      end

      def update(model, opts \\ []) do
        Ecto.Repo.Schema.update(__MODULE__, @adapter, model, opts)
      end

      def insert_or_update(changeset, opts \\ []) do
        Ecto.Repo.Schema.insert_or_update(__MODULE__, @adapter, changeset, opts)
      end

      def delete(model, opts \\ []) do
        Ecto.Repo.Schema.delete(__MODULE__, @adapter, model, opts)
      end

      def insert!(model, opts \\ []) do
        Ecto.Repo.Schema.insert!(__MODULE__, @adapter, model, opts)
      end

      def update!(model, opts \\ []) do
        Ecto.Repo.Schema.update!(__MODULE__, @adapter, model, opts)
      end

      def insert_or_update!(changeset, opts \\ []) do
        Ecto.Repo.Schema.insert_or_update!(__MODULE__, @adapter, changeset, opts)
      end

      def delete!(model, opts \\ []) do
        Ecto.Repo.Schema.delete!(__MODULE__, @adapter, model, opts)
      end

      def preload(model_or_models, preloads) do
        Ecto.Repo.Preloader.preload(model_or_models, __MODULE__, preloads)
      end

      def __adapter__ do
        @adapter
      end

      def __query_cache__ do
        @query_cache
      end

      def __repo__ do
        true
      end

      def __pool__ do
        @pool
      end

      def log(entry) do
        Logger.unquote(@log_level)(fn ->
          {_entry, iodata} = Ecto.LogEntry.to_iodata(entry)
          iodata
        end, ecto_conn_pid: entry.connection_pid)
      end

      defoverridable [log: 1, __pool__: 0]
    end
  end
end
