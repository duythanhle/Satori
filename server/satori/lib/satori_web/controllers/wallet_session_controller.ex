defmodule SatoriWeb.WalletSessionController do
  use SatoriWeb, :controller

  alias Satori.Wallets
  alias Satori.Wallets.Wallet
  alias SatoriWeb.WalletAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{
        "wallet" =>
          %{"message" => message, "signature" => signature, "address" => pubkey} = params
      }) do
    ## Add verify wallet here
    if verify!(message, signature, pubkey) do
      if wallet = Wallets.get_wallet_by_address(pubkey) do
        WalletAuth.log_in_wallet(conn, wallet, params)
      else
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        render(conn, "new.html", error_message: "Invalid wallet")
      end
    else
      render(conn, "new.html", error_message: "Invalid wallet")
    end

    # if user = Accounts.get_user_by_public_key(public_key) do
    #   UserAuth.log_in_user(conn, user, user_params)
    # else
    #   render(conn, "wallet.html", error_message: "Invalid wallet")
    # end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> WalletAuth.log_out_wallet()
  end

  defp verify!(_message, _signature, _pubkey) do
    true
  end
end