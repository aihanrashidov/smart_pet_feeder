defmodule SmartPetFeederApp.Users do
  use Ecto.Schema
  import Ecto.Changeset

  alias SmartPetFeederApp.Pets

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    timestamps(type: :utc_datetime)
    has_many(:pets, Pets, on_delete: :delete_all)
  end

  def changeset(users, attrs) do
    users
    |> cast(attrs, [
      :username,
      :password,
      :password_hash,
      :email,
      :first_name,
      :last_name,
      ])
    |> validate_required([:password, :username])
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(
          changeset,
          :password_hash,
          Comeonin.Bcrypt.hashpwsalt(password)
        )

      _ ->
        changeset
    end
  end

end