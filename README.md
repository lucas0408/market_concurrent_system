# Market System

A concurrent stock management system built with Elixir/Erlang using GenServer, implementing data persistence and connection pooling.

## Overview

Market System is a distributed application that demonstrates Elixir's concurrency model through a stock management system for multiple markets. The system uses GenServer processes to handle individual market inventories, ensuring data consistency across concurrent operations.

## Features

- **Concurrent Process Management**: Each market operates as an independent GenServer process.
- **Data Persistence**: All market data is persisted to disk, allowing recovery after restarts.
- **Process Registry**: A caching mechanism for efficient process lookup.
- **CRUD Operations**: Complete product management with add, update, delete, and retrieval functionality.

## Architecture

The system is built around several key components:

- `Market.Stock`: GenServer implementation for individual market inventory management.
- `Market.Cache`: Process registry that maintains references to active market processes.
- `Market.Database`: Persistence layer for storing market data to disk.

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/market-system.git
cd market-system

# Get dependencies
mix deps.get

# Run the application
iex -S mix
```

## Usage Example

```elixir
# Start the cache server
{:ok, cache} = Market.Cache.start()

# Get a reference to a market (creates a new one if it doesn't exist)
bobs_list = Market.Cache.return_server_pid(cache, "Bob's list")

# Add a product to the market
product_id = Market.Stock.add_product(bobs_list, %{
  name: "linguissa",
  quantity: 5,
  expirate_date: {2023, 8, 8},
  price: 23.45
})

# Get product details
Market.Stock.get_product(bobs_list, product_id)
# Returns: %{name: "linguissa", quantity: 5, expirate_date: {2023, 8, 8}, price: 23.45}

# Update a product
Market.Stock.update_product(bobs_list, product_id, %{
  name: "linguissa",
  quantity: 10,
  expirate_date: {2023, 8, 15},
  price: 24.99
})

# Delete a product
Market.Stock.delete_product(bobs_list, product_id)
```

## Technical Details

This project demonstrates several important concepts in Elixir/Erlang concurrent programming:

- **Process Isolation**: Each market runs in its own process, providing fault tolerance.
- **Message Passing**: All operations are performed through asynchronous message passing.
- **State Management**: Each process maintains its own state, updated through messages.
- **Persistence**: Data is written to disk to survive system restarts.
- **Process Registration**: Markets are registered in a cache for easy lookup.

The system uses a two-phase initialization pattern in GenServer to ensure proper loading of data from the persistence layer.

### Key Implementation Aspects

- **Deferred Initialization**: `Market.Stock` uses a self-message to properly initialize after process start.
- **Process Registry**: `Market.Cache` serves as a registry mapping market names to their PIDs.
- **Persistent Storage**: `Market.Database` handles saving and retrieving market data to/from disk.

## Requirements

- Elixir 1.17 or higher
- Erlang/OTP 26 or higher
>>>>>>> 908802e35d7b7889e4ed6e75843dc15e33847d58
