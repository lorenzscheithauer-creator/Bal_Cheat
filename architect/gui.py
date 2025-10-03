import customtkinter as ctk
import requests
import logging

# Configure basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

API_URL = "http://127.0.0.1:8000"

class App(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Architect Controller")
        self.geometry("400x260")

        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        # --- Sidebar Frame ---
        self.sidebar_frame = ctk.CTkFrame(self, width=140, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, rowspan=4, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(5, weight=1)

        self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="Architect", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 10))

        self.start_button = ctk.CTkButton(self.sidebar_frame, text="Start", command=lambda: self.send_command("start"))
        self.start_button.grid(row=1, column=0, padx=20, pady=10)

        self.pause_button = ctk.CTkButton(self.sidebar_frame, text="Pause", command=lambda: self.send_command("pause"))
        self.pause_button.grid(row=2, column=0, padx=20, pady=10)

        self.stop_button = ctk.CTkButton(self.sidebar_frame, text="Stop", command=lambda: self.send_command("stop"))
        self.stop_button.grid(row=3, column=0, padx=20, pady=10)


        # --- Main Content Frame ---
        self.main_frame = ctk.CTkFrame(self)
        self.main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        self.main_frame.grid_columnconfigure(1, weight=1)

        # Status Label
        self.status_label_title = ctk.CTkLabel(self.main_frame, text="Status:")
        self.status_label_title.grid(row=0, column=0, padx=10, pady=(10, 5), sticky="w")
        self.status_label_value = ctk.CTkLabel(self.main_frame, text="--", font=ctk.CTkFont(size=16, weight="bold"))
        self.status_label_value.grid(row=0, column=1, padx=10, pady=(10, 5), sticky="e")

        # Risk Slider
        self.risk_label = ctk.CTkLabel(self.main_frame, text="Risk Level:")
        self.risk_label.grid(row=1, column=0, columnspan=2, padx=10, pady=(10, 0), sticky="w")
        self.risk_slider = ctk.CTkSlider(self.main_frame, from_=0, to=1, number_of_steps=100, command=self.set_risk)
        self.risk_slider.grid(row=2, column=0, columnspan=2, padx=10, pady=(5, 20), sticky="ew")
        self.risk_slider.set(0.5)

        # Start the periodic update
        self.update_status_loop()

    def send_command(self, command_str, value=None):
        """Sends a command to the server's /command endpoint."""
        payload = {"command": command_str}
        if value is not None:
            payload["value"] = value

        try:
            response = requests.post(f"{API_URL}/command", json=payload)
            response.raise_for_status()
            logging.info(f"Command '{command_str}' sent successfully with value {value}.")
        except requests.exceptions.RequestException as e:
            logging.error(f"Failed to send command '{command_str}': {e}")
            self.update_connection_status(False)

    def set_risk(self, value):
        """Sends the new risk value to the server via the /command endpoint."""
        risk_value = round(float(value), 2)
        self.send_command("set_risk", risk_value)

    def update_status_loop(self):
        """Periodically fetches the state from the server and updates the UI."""
        try:
            response = requests.get(f"{API_URL}/state")
            response.raise_for_status()
            self.update_ui(response.json())
            self.update_connection_status(True)
        except requests.exceptions.RequestException:
            # Don't log every failed poll, just update the UI
            self.update_connection_status(False)

        # Schedule the next update
        self.after(500, self.update_status_loop)

    def update_connection_status(self, is_connected):
        if not is_connected:
            self.status_label_value.configure(text="Disconnected", text_color="red")
        # On successful reconnect, the UI will be updated by update_ui

    def update_ui(self, state):
        """Updates the UI elements with the given state."""
        status = state.get("status", "unknown")
        risk = state.get("risk", 0.5)

        self.status_label_value.configure(text=status.capitalize())
        if status == "running":
            self.status_label_value.configure(text_color="green")
        elif status == "paused":
            self.status_label_value.configure(text_color="yellow")
        else: # stopped, unknown, etc.
            self.status_label_value.configure(text_color="orange")

        if abs(self.risk_slider.get() - risk) > 0.01:
             self.risk_slider.set(risk)


if __name__ == "__main__":
    ctk.set_appearance_mode("System")
    ctk.set_default_color_theme("blue")

    app = App()
    app.mainloop()