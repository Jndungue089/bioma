import serial
import json
import requests
import time
import sys
import threading

SERIAL_PORT = '/dev/ttyUSB0'  # Modifique para a porta COM correspondente no Windows, ex: 'COM3'
BAUD_RATE = 9600
API_URL = 'http://127.0.0.1:5000/api/sensor/current'

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2)
        print(f"Conectado ao Arduino na porta {SERIAL_PORT}")
    except serial.SerialException as e:
        print(f"ERRO: Não foi possivel conectar a {SERIAL_PORT}. {e}")
        return

    while True:
        try:
            line = ser.readline().decode('utf-8', errors='ignore').strip()
            if line:
                print(f"[ARDUINO] {line}")
                # Esperamos um output JSON
                if line.startswith('{') and line.endswith('}'):
                    try:
                        data = json.loads(line)
                        if data.get('source') == 'arduino_bio':
                            # Post to the API endpoint
                            res = requests.post(API_URL, json=data, timeout=2)
                            print(f"[BRIDGE] Atualizado na API: {res.status_code}")
                    except json.JSONDecodeError:
                        pass
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"[BRIDGE ERRO] {e}")
            time.sleep(1)

if __name__ == '__main__':
    main()
