defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_maps
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid (image) do
    %Identicon.Image{hex: hex_list} = image
    grid =
      hex_list
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

      %Identicon.Image{image | grid: grid}
  end

  def mirror_row (row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(image) do
    %Identicon.Image{grid: grid} = image
    grid_filter =
      grid
      |> Enum.filter(fn({code, _index}) ->
        rem(code, 2) == 0
      end)

     %Identicon.Image{image | grid: grid_filter}
  end

  def build_pixel_maps(image) do
    %Identicon.Image{grid: grid} = image

    pixel_maps = Enum.map(grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end)

    %Identicon.Image{image | pixel_maps: pixel_maps}
  end

  def draw_image(image) do
    %Identicon.Image{color: color, pixel_maps: pixel_maps} = image
    image_creation = :egd.create(250, 250)
    fill_color = :egd.color(color)

    Enum.each(pixel_maps, fn ({start_point, stop_point}) ->
      :egd.filledRectangle(image_creation, start_point, stop_point, fill_color)
    end)

    :egd.render(image_creation)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

end
