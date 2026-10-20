# BIOMA

Aplicação de **triagem de saúde por assimetria térmica**. Um sensor ligado a um Arduino mede a temperatura em dois lados do corpo; a app compara os valores e indica o nível de risco ao paciente.

## Como funciona

1. O paciente inicia sessão (email + PIN) e começa uma triagem.
2. O Arduino envia as leituras por porta série; `api/serial_bridge.py` reencaminha-as para a API.
3. A API calcula o risco pela diferença entre as duas temperaturas:

| Diferença | Resultado |
|---|---|
| menor que 1 °C | Normal |
| de 1 °C a menos de 2 °C | Atenção |
| 2 °C ou mais | Alto Risco |

4. A app mostra o resultado com recomendações e, em caso de alto risco, sugere consulta urgente e o centro de saúde mais próximo.

## Componentes

```
lib/          App Flutter (login, registo, dados clínicos, recolha, triagem, resultado, histórico, perfil)
api/          API Flask + SQLite (pacientes, triagens, leitura atual do sensor)
api/serial_bridge.py   Ponte Arduino → API
```

**App:** Flutter, `provider`, `http`, `shared_preferences`, `intl`. **API:** Flask, Flask-SQLAlchemy.

## Executar

```bash
# API
cd api
pip install -r requirements.txt
python app.py                # http://127.0.0.1:5000

# Ponte com o Arduino (ajuste a porta em serial_bridge.py)
python serial_bridge.py

# App
flutter pub get
flutter run
```

Principais rotas: `POST /api/login`, `GET/POST /api/pacientes`, `POST /api/triagens`, `GET /api/pacientes/<id>/triagens`, `GET/POST /api/sensor/current`.

> Projeto académico. Não substitui avaliação médica.
