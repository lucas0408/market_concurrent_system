defmodule Market.DatabaseWorker do
    use GenServer

    def start(db_folder) do
        GenServer.start(__MODULE__, db_folder)
    end

    def get(worker_pid, key) do
        GenServer.call(worker_pid, {:get, key})
    end

    def store(worker_pid, key, data) do
        GenServer.cast(worker_pid, {:store, key, data})
    end

    @impl GenServer
    def init(db_folder) do
        File.mkdir_p(db_folder)
        {:ok, db_folder}
    end

    @impl GenServer
    def handle_cast({:store, key, data}, db_folder) do
        path_file(db_folder, key)
        |> File.write!(:erlang.term_to_binary(data))
        {:noreply, db_folder}

    end

    @impl GenServer
    def handle_call({:get, key}, _from, db_folder) do
        data = case File.read(path_file(db_folder, key)) do
            {:ok, contents} ->
                :erlang.binary_to_term(contents)
            _ ->
                nil
        end
        {:reply, data, db_folder}
    end

    defp path_file(db_folder, key) do
        "#{db_folder}/#{key}"
    end

end