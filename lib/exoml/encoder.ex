defmodule Exoml.Encoder do

  def encode({:root, _, children}) when is_list(children) do
    encode(children, "")
  end

  defp encode(bin, acc) when is_binary(bin) do
    acc <> bin
  end

  defp encode([node | tl], acc) do
    encode(tl, encode(node, acc))
  end

  defp encode([], acc), do: acc

  defp encode({:prolog, attrs, nil}, acc) do
    acc <> "<?xml " <> encode_attrs(attrs) <> " ?>"
  end

  defp encode({:doctype, attrs, nil}, acc) do
    acc <> "<!DOCTYPE" <> encode_attrs(attrs) <> " !>"
  end

  defp encode({tag, [], nil}, acc) do
    acc <> "<#{tag}/>"
  end

  defp encode({tag, attrs, nil}, acc) do
    acc <> "<#{tag} #{encode_attrs(attrs)} />"
  end

  defp encode({tag, [], children}, acc) do
    acc <> "<#{tag}>" <> encode(children, "") <> "</#{tag}>"
  end

  defp encode({tag, attrs, children}, acc) do
    acc <> "<" <> tag <> " " <> encode_attrs(attrs) <> ">" <> encode(children, "") <> "</#{tag}>"
  end

  defp encode_attrs(attrs) do
    encode_attrs(attrs, "")
  end

  defp encode_attrs([attr | tl], acc) do
    trail = encode_attr(attr)
    if acc == "" do
      encode_attrs(tl, trail)
    else
      encode_attrs(tl, acc <> " " <> trail)
    end
  end

  defp encode_attrs([], acc), do: acc

  defp encode_attr({single}), do: single

  defp encode_attr({name, value}) do
    qt = cond do
      Regex.match?(~r/"/, value) -> "'"
      Regex.match?(~r/'/, value) -> ~s'"'
      true -> ~s'"'
    end
    "#{name}=#{qt}#{value}#{qt}"
  end

  defp encode_attr(bin), do: bin

end

