
import os
import threading
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# Variaveis globais de estado do sensor
sensor_data_atual = None


app = Flask(__name__)
# Configuração do banco de dados SQLite
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'bioma.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Modelos
class Paciente(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    pin = db.Column(db.String(20), nullable=False)
    idade = db.Column(db.Integer, nullable=False)
    telefone = db.Column(db.String(20))
    localizacao = db.Column(db.String(100))
    data_nascimento = db.Column(db.String(20))
    centro_saude = db.Column(db.String(100))
    agente_saude = db.Column(db.String(100))
    triagens = db.relationship('Triagem', backref='paciente', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'nome': self.nome,
            'email': self.email,
            'idade': self.idade,
            'telefone': self.telefone,
            'localizacao': self.localizacao,
            'data_nascimento': self.data_nascimento,
            'centro_saude': self.centro_saude,
            'agente_saude': self.agente_saude
        }

class Triagem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    paciente_id = db.Column(db.Integer, db.ForeignKey('paciente.id'), nullable=False)
    data_hora = db.Column(db.DateTime, default=datetime.utcnow)
    temp_mama_esq = db.Column(db.Float, nullable=False)
    temp_mama_dir = db.Column(db.Float, nullable=False)
    bpm = db.Column(db.Integer)
    spo2 = db.Column(db.Integer)
    nivel_atividade = db.Column(db.String(50))
    classificacao_risco = db.Column(db.String(20)) # Normal, Atenção, Alto Risco
    
    def to_dict(self):
        return {
            'id': self.id,
            'paciente_id': self.paciente_id,
            'data_hora': self.data_hora.isoformat(),
            'temp_mama_esq': self.temp_mama_esq,
            'temp_mama_dir': self.temp_mama_dir,
            'bpm': self.bpm,
            'spo2': self.spo2,
            'nivel_atividade': self.nivel_atividade,
            'classificacao_risco': self.classificacao_risco
        }

# Função auxiliar para classificar risco baseada nos requisitos
def calcular_risco(temp_esq, temp_dir):
    diff = abs(temp_esq - temp_dir)
    if diff >= 2.0:
        return 'Alto Risco'
    elif diff >= 1.0:
        return 'Atenção'
    else:
        return 'Normal'

with app.app_context():
    db.create_all()
    # Mock user creation if not exists
    if not Paciente.query.filter_by(email='maria@bioma.com').first():
        maria = Paciente(
            nome='Maria Fernandes',
            email='maria@bioma.com',
            pin='1234',
            idade=34,
            telefone='999999999',
            localizacao='Luanda, Angola',
            data_nascimento='12/04/1992',
            centro_saude='C.S. Rangel, Luanda',
            agente_saude='Enfermeira Ana Costa'
        )
        db.session.add(maria)
        db.session.commit()

# Rotas (Endpoints API)
@app.route('/api/pacientes', methods=['GET'])
def get_pacientes():
    pacientes = Paciente.query.all()
    return jsonify([p.to_dict() for p in pacientes])

@app.route('/api/pacientes/<int:id>', methods=['GET'])
def get_paciente(id):
    paciente = Paciente.query.get_or_404(id)
    return jsonify(paciente.to_dict())

@app.route('/api/login', methods=['POST'])
def login():
    dados = request.get_json()
    email = dados.get('email')
    pin = dados.get('pin')
    
    paciente = Paciente.query.filter_by(email=email).first()
    
    if not paciente:
        return jsonify({'error': 'Utilizador não encontrado'}), 404
    
    if paciente.pin != str(pin):
        return jsonify({'error': 'PIN incorreto'}), 401
    
    return jsonify({'token': str(paciente.id), 'paciente': paciente.to_dict()}), 200

@app.route('/api/pacientes', methods=['POST'])
def add_paciente():
    dados = request.get_json()
    
    if Paciente.query.filter_by(email=dados['email']).first():
        return jsonify({'error': 'Email já registado'}), 400
        
    novo_paciente = Paciente(
        nome=dados['nome'],
        email=dados['email'],
        pin=dados['pin'],
        idade=dados['idade'],
        telefone=dados.get('telefone', ''),
        localizacao=dados.get('localizacao', ''),
        data_nascimento=dados.get('data_nascimento', ''),
        centro_saude=dados.get('centro_saude', ''),
        agente_saude=dados.get('agente_saude', '')
    )
    db.session.add(novo_paciente)
    db.session.commit()
    return jsonify(novo_paciente.to_dict()), 201


@app.route('/api/pacientes/<int:id>', methods=['PUT'])
def update_paciente(id):
    paciente = Paciente.query.get_or_404(id)
    dados = request.get_json()
    
    if 'nome' in dados: paciente.nome = dados['nome']
    if 'idade' in dados: paciente.idade = dados['idade']
    if 'telefone' in dados: paciente.telefone = dados['telefone']
    if 'localizacao' in dados: paciente.localizacao = dados['localizacao']
    if 'data_nascimento' in dados: paciente.data_nascimento = dados['data_nascimento']
    if 'centro_saude' in dados: paciente.centro_saude = dados['centro_saude']
    if 'agente_saude' in dados: paciente.agente_saude = dados['agente_saude']
    
    db.session.commit()
    return jsonify(paciente.to_dict()), 200


@app.route('/api/sensor/current', methods=['POST'])
def set_sensor_data():
    global sensor_data_atual
    dados = request.get_json()
    sensor_data_atual = dados
    # print(f"Dados do sensor recebidos do arduino_bio {dados}")
    return jsonify({"status": "ok"}), 200

@app.route('/api/sensor/current', methods=['GET'])
def get_sensor_data():
    global sensor_data_atual
    if sensor_data_atual is None:
        return jsonify({"error": "Nenhum dado recebido do hardware"}), 404
    return jsonify(sensor_data_atual), 200

@app.route('/api/sensor/clear', methods=['POST'])
def clear_sensor_data():
    global sensor_data_atual
    sensor_data_atual = None
    return jsonify({"status": "cleared"}), 200

@app.route('/api/triagens', methods=['POST'])

def add_triagem():
    dados = request.get_json()
    
    # Processamento automático e classificação de risco
    temp_esq = float(dados['temp_mama_esq'])
    temp_dir = float(dados['temp_mama_dir'])
    risco = calcular_risco(temp_esq, temp_dir)
    
    nova_triagem = Triagem(
        paciente_id=dados['paciente_id'],
        temp_mama_esq=temp_esq,
        temp_mama_dir=temp_dir,
        bpm=dados.get('bpm', 0),
        spo2=dados.get('spo2', 0),
        nivel_atividade=dados.get('nivel_atividade', 'Desconhecido'),
        classificacao_risco=risco
    )
    db.session.add(nova_triagem)
    db.session.commit()
    return jsonify(nova_triagem.to_dict()), 201

@app.route('/api/pacientes/<int:paciente_id>/triagens', methods=['GET'])
def get_triagens_paciente(paciente_id):
    triagens = Triagem.query.filter_by(paciente_id=paciente_id).order_by(Triagem.data_hora.desc()).all()
    return jsonify([t.to_dict() for t in triagens])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
