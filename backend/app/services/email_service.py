import os
import smtplib
import ssl
import html

from email.message import EmailMessage
from pathlib import Path
from dotenv import load_dotenv


# Load backend/.env
ENV_PATH = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(ENV_PATH)


def send_otp_email(recipient_email: str, otp_code: str) -> None:
    sender_email = os.getenv("SMTP_EMAIL")
    app_password = os.getenv("SMTP_APP_PASSWORD")

    smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))

    if not sender_email or not app_password:
        raise RuntimeError(
            "SMTP_EMAIL or SMTP_APP_PASSWORD is missing."
        )

    # Escape dynamic values before using them in HTML.
    safe_code = html.escape(otp_code)

    # Create the email.
    message = EmailMessage()

    message["From"] = f"TilapiaSize <{sender_email}>"
    message["To"] = recipient_email
    message["Subject"] = "Your TilapiaSize Email Verification Code"

    # Plain-text version for email apps that don't support HTML.
    message.set_content(
        "TilapiaSize - Email Verification\n\n"
        "Hello Farmer,\n\n"
        "Thank you for joining TilapiaSize!\n\n"
        f"Your verification code is: {otp_code}\n\n"
        "This code expires in 2 minutes.\n\n"
        "Never share this code with anyone.\n\n"
        "If you did not request this code, ignore this email.\n\n"
        "TilapiaSize Team"
    )

    # Professional HTML email design.
    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">
        <title>TilapiaSize Email Verification</title>
    </head>

    <body style="
        margin: 0;
        padding: 30px 12px;
        background-color: #eaf1f0;
        font-family: Arial, Helvetica, sans-serif;
    ">

        <table role="presentation"
               cellpadding="0"
               cellspacing="0"
               border="0"
               width="100%"
               style="max-width: 520px;
                      margin: 0 auto;
                      background-color: #ffffff;
                      border-radius: 16px;
                      overflow: hidden;">

            <!-- HEADER -->
            <tr>
                <td align="center"
                    style="
                        background-color: #103a3d;
                        padding: 32px 20px;
                    ">

                    <h1 style="
                        color: #ffffff;
                        font-size: 30px;
                        margin: 0;
                        letter-spacing: 0.5px;
                    ">
                        TilapiaSize
                    </h1>

                    <p style="
                        color: #b5d8d2;
                        font-size: 13px;
                        margin: 8px 0 0;
                    ">
                        Smart Tilapia Size Grading
                    </p>

                </td>
            </tr>

            <!-- EMAIL CONTENT -->
            <tr>
                <td style="padding: 34px 28px;">

                    <h2 style="
                        color: #103a3d;
                        font-size: 23px;
                        text-align: center;
                        margin: 0 0 24px;
                    ">
                        Verify your email address
                    </h2>

                    <p style="
                        color: #475569;
                        font-size: 15px;
                        line-height: 1.7;
                    ">
                        Hello Farmer,
                    </p>

                    <p style="
                        color: #475569;
                        font-size: 15px;
                        line-height: 1.7;
                    ">
                        Thank you for joining
                        <strong>TilapiaSize!</strong>
                        Please enter the verification code
                        below to confirm your email address
                        and continue setting up your account.
                    </p>

                    <!-- OTP CODE -->
                    <table role="presentation"
                           cellpadding="0"
                           cellspacing="0"
                           border="0"
                           width="100%"
                           style="
                               background-color: #eff8f6;
                               border: 1px solid #c9e8e1;
                               border-radius: 12px;
                               margin: 26px 0;
                           ">

                        <tr>
                            <td align="center"
                                style="padding: 26px 12px;">

                                <p style="
                                    color: #617f7a;
                                    font-size: 11px;
                                    font-weight: bold;
                                    letter-spacing: 2px;
                                    margin: 0 0 12px;
                                ">
                                    YOUR VERIFICATION CODE
                                </p>

                                <div style="
                                    color: #126c64;
                                    font-size: 38px;
                                    font-weight: bold;
                                    letter-spacing: 8px;
                                    line-height: 1.4;
                                ">
                                    {safe_code}
                                </div>

                                <p style="
                                    color: #64748b;
                                    font-size: 13px;
                                    margin: 12px 0 0;
                                ">
                                    Expires in 2 minutes
                                </p>

                            </td>
                        </tr>
                    </table>

                    <p style="
                        color: #475569;
                        font-size: 14px;
                        line-height: 1.7;
                    ">
                        For your security, never share this
                        code with anyone.
                    </p>

                    <hr style="
                        border: 0;
                        border-top: 1px solid #e2e8f0;
                        margin: 28px 0;
                    ">

                    <p style="
                        color: #64748b;
                        font-size: 13px;
                        line-height: 1.7;
                        text-align: center;
                    ">
                        If you didn't create a TilapiaSize
                        account, you can safely ignore
                        this email.
                    </p>

                </td>
            </tr>

            <!-- FOOTER -->
            <tr>
                <td align="center"
                    style="
                        background-color: #f5f8f8;
                        padding: 22px;
                    ">

                    <p style="
                        color: #103a3d;
                        font-size: 13px;
                        font-weight: bold;
                        margin: 0 0 6px;
                    ">
                        TilapiaSize Team
                    </p>

                    <p style="
                        color: #64748b;
                        font-size: 11px;
                        margin: 0;
                    ">
                        Automated verification email
                        &middot; Please do not reply
                    </p>

                </td>
            </tr>

        </table>

    </body>
    </html>
    """

    # Include both text and HTML versions.
    message.add_alternative(
        html_content,
        subtype="html"
    )

    # Send email securely via Gmail SMTP.
    with smtplib.SMTP(
        smtp_host,
        smtp_port,
        timeout=20
    ) as server:

        server.ehlo()

        server.starttls(
            context=ssl.create_default_context()
        )

        server.ehlo()

        server.login(
            sender_email,
            app_password
        )

        server.send_message(message)

    
def send_password_reset_email(
    recipient_email: str,
    otp_code: str,
) -> None:
    sender_email = os.getenv("SMTP_EMAIL")
    app_password = os.getenv("SMTP_APP_PASSWORD")
    smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))

    if not sender_email or not app_password:
        raise RuntimeError(
            "SMTP email settings are missing."
        )

    safe_code = html.escape(otp_code)

    message = EmailMessage()
    message["From"] = f"TilapiaSize <{sender_email}>"
    message["To"] = recipient_email
    message["Subject"] = "TilapiaSize - Password Reset Code"

    message.set_content(
        "TilapiaSize Password Reset\n\n"
        "Hello Farmer,\n\n"
        "We received a request to reset your password.\n\n"
        f"Your password reset code is: {otp_code}\n\n"
        "This code expires in 2 minutes.\n\n"
        "If you did not request a password reset, "
        "you can safely ignore this email.\n\n"
        "Never share this code with anyone.\n\n"
        "TilapiaSize Team"
    )

    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">
    </head>
    <body style="
        margin:0;
        padding:30px 12px;
        background-color:#eaf1f0;
        font-family:Arial,Helvetica,sans-serif;
    ">
        <table role="presentation"
               cellpadding="0"
               cellspacing="0"
               border="0"
               width="100%"
               style="
                   max-width:520px;
                   margin:0 auto;
                   background-color:#ffffff;
                   border-radius:16px;
               ">
            <tr>
                <td align="center"
                    style="
                        background-color:#103a3d;
                        padding:32px 20px;
                    ">
                    <h1 style="
                        color:#ffffff;
                        font-size:30px;
                        margin:0;
                    ">
                        TilapiaSize
                    </h1>
                    <p style="
                        color:#b5d8d2;
                        font-size:13px;
                    ">
                        Smart Tilapia Size Grading
                    </p>
                </td>
            </tr>

            <tr>
                <td style="padding:34px 28px;">
                    <h2 style="
                        color:#103a3d;
                        text-align:center;
                        font-size:23px;
                    ">
                        Reset Your Password
                    </h2>

                    <p style="
                        color:#475569;
                        font-size:15px;
                        line-height:1.7;
                    ">
                        Hello Farmer,
                    </p>

                    <p style="
                        color:#475569;
                        font-size:15px;
                        line-height:1.7;
                    ">
                        We received a request to reset
                        your TilapiaSize account password.
                        Enter this code in the app to
                        continue.
                    </p>

                    <table role="presentation"
                           width="100%"
                           cellpadding="0"
                           cellspacing="0"
                           style="
                               background-color:#eff8f6;
                               border:1px solid #c9e8e1;
                               border-radius:12px;
                           ">
                        <tr>
                            <td align="center"
                                style="padding:26px 12px;">
                                <p style="
                                    font-size:11px;
                                    color:#617f7a;
                                    letter-spacing:2px;
                                ">
                                    PASSWORD RESET CODE
                                </p>

                                <div style="
                                    color:#126c64;
                                    font-size:38px;
                                    font-weight:bold;
                                    letter-spacing:8px;
                                ">
                                    {safe_code}
                                </div>

                                <p style="
                                    color:#64748b;
                                    font-size:13px;
                                ">
                                    Expires in 2 minutes
                                </p>
                            </td>
                        </tr>
                    </table>

                    <p style="
                        color:#475569;
                        font-size:14px;
                        line-height:1.7;
                        margin-top:24px;
                    ">
                        If you didn't request a password
                        reset, you can safely ignore
                        this email. Your password will
                        remain unchanged.
                    </p>

                    <p style="
                        color:#64748b;
                        font-size:13px;
                    ">
                        Never share this code with anyone.
                    </p>
                </td>
            </tr>

            <tr>
                <td align="center"
                    style="
                        background-color:#f5f8f8;
                        padding:22px;
                    ">
                    <p style="
                        color:#103a3d;
                        font-weight:bold;
                        font-size:13px;
                    ">
                        TilapiaSize Team
                    </p>
                    <p style="
                        color:#64748b;
                        font-size:11px;
                    ">
                        Automated security email
                        &middot; Please do not reply
                    </p>
                </td>
            </tr>
        </table>
    </body>
    </html>
    """

    message.add_alternative(
        html_content,
        subtype="html",
    )

    with smtplib.SMTP(
        smtp_host,
        smtp_port,
        timeout=20,
    ) as server:
        server.ehlo()
        server.starttls(
            context=ssl.create_default_context()
        )
        server.ehlo()
        server.login(sender_email, app_password)
        server.send_message(message)

