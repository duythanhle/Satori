defmodule SatoriWeb.UserSessionController do
  use SatoriWeb, :controller

  alias Satori.Accounts
  alias SatoriWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def wallet(conn, _params) do
    render(conn, "wallet.html", error_message: nil)
  end

  def create(conn, %{"user" => %{"public_key" => public_key} = user_params}) do
    ## Add verify wallet here
    if user = Accounts.get_user_by_public_key(public_key) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      render(conn, "wallet.html", error_message: "Invalid wallet")
    end
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
