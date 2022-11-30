defmodule Packmatic.Field.Shared.ExtendedInformation do
  @moduledoc """
  Represents the Zip64 Extended Information Extra Field, which can be emitted in both Local and
  Central File Headers, but in practice only used in the Central File Header within Packmatic, due
  to its streaming nature.

  Furthermore, disregarding the APPNOTE’s indication that the field should only be used if the
  sizes are set to `0xFF 0xFF` / `0xFF 0xFF 0xFF 0xFF`, since Packmatic _always_ skips the file
  sizes in the Local File Header (due to the archive being generated in a streaming fashionn), and
  _always_ emits the sizes in the Central Directory File Header as `0xFF 0xFF 0xFF 0xFF` for
  simplicity, the Zip64 Extended Information Extra Field is _never_ emitted by Packmatic in the
  Local File Header, and _always_ emitted by Packmatic in the Central Directory File Header, with
  both Uncompressed and Compressed Sizes.

  ## Structure

  ### Shared Zip64 Extended Information

  Size     | Content
  -------- | -
  2 bytes  | 0x0001 - Tag for this "extra" block type
  2 bytes  | Size of this "extra" block
  8 bytes  | Original Size (Bytes)
  8 bytes  | Compressed Size (Bytes)
  8 bytes  | Offset of local header record
  4 bytes  | Number of the disk on which this file starts
  """

  @type t :: %__MODULE__{size: non_neg_integer(), size_compressed: non_neg_integer(), offset: non_neg_integer()}
  @enforce_keys ~w(size size_compressed offset)a
  defstruct size: 0, size_compressed: 0, offset: 0
end

defimpl Packmatic.Field, for: Packmatic.Field.Shared.ExtendedInformation do
  def encode(target) do
    size = target.size
    size_compressed = target.size_compressed
    offset = target.offset

    [
      <<0x0001::little-size(16)>>,
      <<28::little-size(16)>>,
      <<size::little-size(64)>>,
      <<size_compressed::little-size(64)>>,
      <<offset::little-size(64)>>,
      <<0::little-size(32)>>
    ]
  end
end
