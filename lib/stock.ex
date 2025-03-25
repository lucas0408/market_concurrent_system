defmodule Market.Stock do
  use GenServer

  defstruct auto_id: 1, products: %{}

  def start(market_name) do
    GenServer.start(__MODULE__, market_name)
  end

  def add_product(stock_pid, product) do
    GenServer.call(stock_pid, {:add_product, product})
  end

  def update_product(stock_pid, product_id, update_product) do
    GenServer.cast(stock_pid, {:update_product, product_id, update_product})
  end

  def delete_product(stock_pid, product_id) do
    GenServer.cast(stock_pid, {:delete_product, product_id})
  end

  def get_product(stock_pid, product_id) do
    GenServer.call(stock_pid, {:get_product, product_id})
  end

  @impl GenServer
  def init(market_name) do
    send(self(), {:real_init, market_name})
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:add_product, product}, _from, {name, stock}) do
    new_product = Map.put(stock.products, stock.auto_id, product)
    new_state =  %Market.Stock{stock | products: new_product, auto_id: stock.auto_id + 1}
    Market.Database.store(name, new_state)
    {
      :reply,
      stock.auto_id,
      {name, new_state}
    }
  end

  @impl GenServer
  def handle_cast({:update_product, product_id, update_product}, {name, stock}) do
    updated_products = Map.replace(stock.products, product_id, update_product)
    new_state = %Market.Stock{stock | products: updated_products}
    Market.Database.store(name, new_state)
    {
      :noreply,
      {name, new_state}
    }
  end

  @impl GenServer
    def handle_cast({:delete_product, product_id}, {name, stock}) do
    updated_products = Map.delete(stock.products, product_id)
    new_state = %Market.Stock{stock | products: updated_products}
    Market.Database.store(name, new_state)
    {
      :noreply,
      {name, new_state}
    }
  end

  @impl GenServer
  def handle_call({:get_product, product_id}, _from, {name, stock}) do
    {
      :reply,
      Map.get(stock.products, product_id),
      {name, stock}
    }
  end

  @impl GenServer
  def handle_info({:real_init, market_name}, _stock) do
   {:noreply, {market_name, Market.Database.get(market_name) || %Market.Stock{}}}
  end
end 