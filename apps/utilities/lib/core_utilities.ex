defmodule CoreUtilities do
  @moduledoc false

  @spec validate_name(String.t()) :: boolean
  def validate_name(name) do
    not is_integer(name)
  end

end
