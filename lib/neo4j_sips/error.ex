defmodule Neo4j.Sips.Error do
  @moduledoc """
  This module defines a `Neo4j.Sips.Error` simple structure containing two fields:

  * `code` - the error code
  * `message` - the error details
  """

  defexception [:code, :message]
end
