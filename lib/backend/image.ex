defmodule ImageEditor do
  def apply_gaussian_blur(filename, percentage) do
    image_path = "priv/static/uploads/#{filename}"

    image = Evision.imread(image_path)

    kernel_size = div(percentage, 10) * 2 + 1

    blurred_image = Evision.gaussianBlur(image, {kernel_size, kernel_size}, 0)

    cp_path = "priv/static/uploads/duplicate_#{filename}"

    Evision.imwrite(cp_path, blurred_image)

    {:ok, "Image blurred successfully"}
  end

  def apply_grayscale(filename) do
    image_path = "priv/static/uploads/#{filename}"

    image = Evision.imread(image_path)

    gray_image = Evision.cvtColor(image, 7)

    cp_path = "priv/static/uploads/duplicate_#{filename}"

    Evision.imwrite(cp_path, gray_image)

    {:ok, "Image converted to grayscale successfully"}
  end

  def apply_threshold(filename, percentage) do
    image_path = "priv/static/uploads/#{filename}"

    image= Evision.imread(image_path)

    gray_image = Evision.cvtColor(image, 7)

    threshold_value = round(percentage * 2.55)

    {_value, threshold_image} = Evision.threshold(gray_image, threshold_value, 255, 1)

    cp_path = "priv/static/uploads/duplicate_#{filename}"

    Evision.imwrite(cp_path, threshold_image)

    {:ok, "Threshold applied successfully"}
  end
end
