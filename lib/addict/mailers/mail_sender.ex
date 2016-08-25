defmodule Addict.Mailers.MailSender do
  @moduledoc """
  Sends register and reset token e-mails
  """
  require Logger

  def send_register(user_params) do
    template = Addict.Configs.email_register_template || "<p>Thanks for registering <%= email %>!</p>"
    subject = Addict.Configs.email_register_subject || "Welcome"
    user = user_params |> convert_to_list
    html_body = EEx.eval_string(template, user)
    from_email = Addict.Configs.from_email || "no-reply@addict.github.io"
    Addict.Mailers.send_email(user_params["email"], from_email, subject, html_body)
  end

  def send_reset_token(email, path, host \\ Addict.Configs.host) do
    host = host || "http://localhost:4000"
    template = Addict.Configs.email_reset_password_template || ahead_email(host, path)
    subject = Addict.Configs.email_reset_password_subject || "Reset Password"
    params = %{"email" => email, "path" => path} |> convert_to_list
    html_body = EEx.eval_string(template, params)
    from_email = Addict.Configs.from_email || "no-reply@addict.github.io"
    Addict.Mailers.send_email(email, from_email, subject, html_body)
  end

  def ahead_email(host, path) do
      """
        <p> You have requested a password reset. </p>
        <p> Follow the link below and set a new password </p>
        <p> Click <a href='#{host}<%= path %>'>here</a> to proceed!</p>
        <p> <a href="https://xkcd.com/936/" tabindex="-1" target="_blank" style="font-style: italic;">How to pick a password</a></p>
        """
  end

  defp convert_to_list(params) do
    params
    |> Map.to_list
    |> Enum.reduce([], fn ({key, value}, acc) ->
      Keyword.put(acc, String.to_atom(key), value)
    end)
  end

end
