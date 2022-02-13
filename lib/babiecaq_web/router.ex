defmodule BabiecaqWeb.Router do
  use BabiecaqWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BabiecaqWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BabiecaqWeb do
    pipe_through :browser
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", BabiecaqWeb do
    pipe_through :api

  end
  scope "/api/producer", BabiecaqWeb do
    pipe_through :api

    post "/", ProducerController, :create
  end
  scope "/api/config/topic", BabiecaqWeb do
    pipe_through :api
    get "/", ConfigController, :index
    post "/", ConfigController, :create
    delete "/:topic_name", ConfigController, :delete
    delete "/:topic_name/messages", MessagesController, :delete
    post "/:topic_name/messages", MessagesController, :create
    get "/:topic_name/messages/:user_name", MessagesController, :get
    get "/:topic_name/user", UserController, :index
    post "/:topic_name/user", UserController, :create
  end


  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BabiecaqWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :babiecaq, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "BabiecaQ",
        description: "API Documentation for BabiecaQ",
        termsOfService: "Open for public",
        contact: %{
          name: "Perfecto Vidal Lloret",
          email: "perfecto.vidal.lloret@gmail.com"
        }
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          description:
            "API Token must be provided via `Authorization: Bearer ` header",
          in: "header"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"],
      tags: [
        %{name: "Config Topic", description: "Resources to Config topic"},
        %{name: "Messages", description: "Resources to messages in topic"},
      ]
    }
  end
end
