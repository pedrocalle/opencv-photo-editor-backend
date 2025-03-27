defmodule BackendWeb.ImageController do
  use BackendWeb, :controller

  def delete(conn, _params) do
    uploads_path = "priv/static/uploads"

    case File.rm_rf(uploads_path) do
      {:ok, _} ->
        File.mkdir_p!(uploads_path)
        json(conn, %{message: "Imagem deletada com sucesso!"})

      {:error, reason} ->
        {:error, reason}
    end
  end

  def edit(conn, %{"filename" => filename, "blur_percentage" => blur_percentage, "threshold_percentage" => threshold_percentage, "grayscale" => true}) do

    ImageEditor.apply_gaussian_blur(filename, blur_percentage)

    ImageEditor.apply_grayscale("duplicate_#{filename}")

    ImageEditor.apply_threshold("duplicate_#{filename}", threshold_percentage)

    send_resp(conn, 200, "Image processed successfully")
  end

  def edit(conn, %{"filename" => filename, "blur_percentage" => blur_percentage, "grayscale" => false }) do

    ImageEditor.apply_gaussian_blur(filename, blur_percentage)

    send_resp(conn, 200, "Image processed successfully")
  end

  def edit(conn, %{"filename" => filename, "threshold_percentage" => threshold_percentage, "grayscale" => false }) do

    ImageEditor.apply_threshold(filename, threshold_percentage)

    send_resp(conn, 200, "Image processed successfully")
  end

  def edit(conn, %{"filename" => filename, "grayscale" => true }) do

    ImageEditor.apply_grayscale(filename)

    send_resp(conn, 200, "Image processed successfully")
  end


  def edit(conn, %{"filename" => filename, "blur_percentage" => blur_percentage, "grayscale" => true }) do

    ImageEditor.apply_gaussian_blur(filename, blur_percentage)
    ImageEditor.apply_grayscale("duplicate_#{filename}")

    send_resp(conn, 200, "Image processed successfully")
  end

  def edit(conn, %{"filename" => filename, "grayscale" => false}) do
    original_path = "priv/static/uploads/#{filename}"
    duplicate_path = "priv/static/uploads/duplicate_#{filename}"

    if File.exists?(original_path) do
      File.cp!(original_path, duplicate_path)
    end

    send_resp(conn, 200, "Image duplicated successfully")
  end

  def edit(conn, %{"filename" => filename, "threshold_percentage" => threshold_percentage, "grayscale" => true }) do

    ImageEditor.apply_threshold(filename, threshold_percentage)

    send_resp(conn, 200, "Image processed successfully")
  end

  def edit(conn, %{"filename" => filename, "blur_percentage" => blur_percentage, "threshold_percentage" => threshold_percentage, "grayscale" => false}) do

    ImageEditor.apply_gaussian_blur(filename, blur_percentage)

    ImageEditor.apply_threshold("duplicate_#{filename}", threshold_percentage)

    send_resp(conn, 200, "Image processed successfully")
  end

  def upload(conn, %{"file" => %Plug.Upload{filename: filename, path: path}}) do
    dest_path = Path.join(["priv/static/uploads", filename])

    File.cp!(path, dest_path)

    duplicate_filename = "duplicate_#{filename}"
    duplicate_dest_path = Path.join(["priv/static/uploads", duplicate_filename])

    File.cp!(path, duplicate_dest_path)

    json(conn, %{message: "Upload realizado com sucesso!", filename: filename})
  end

  def download(conn, %{"filename" => filename}) do
    duplicate_path = "priv/static/uploads/duplicate_#{filename}"

    if File.exists?(duplicate_path) do
      conn
      |> put_resp_content_type("image/jpeg")
      |> send_file(200, duplicate_path)
    else
      send_resp(conn, 404, "File not found")
    end
  end

  def show(conn, %{"filename" => filename}) do
    upload_path = Path.join("priv/static/uploads", filename)

    if File.exists?(upload_path) do
      conn
      |> put_resp_content_type(get_mime_type(filename))
      |> send_file(200, upload_path)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "File not found"})
    end
  end

  defp get_mime_type(filename) do
    case Path.extname(filename) do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".gif" -> "image/gif"
      _ -> "application/octet-stream"
    end
  end
end
