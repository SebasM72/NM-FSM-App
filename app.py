import os
from flask import Flask, request, flash, url_for, redirect, render_template
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
    'DATABASE_URL',
    'sqlite:///students.sqlite3'
)
app.config['SECRET_KEY'] = "random string"
db = SQLAlchemy(app)

def major_enabled():
    return os.environ.get("ENABLE_MAJOR_FIELD", "false").lower() == "true"

class Students(db.Model):
    id = db.Column('student_id', db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    city = db.Column(db.String(50))
    addr = db.Column(db.String(200))
    pin = db.Column(db.String(10))
    phone_number = db.Column(db.String(20))
    major = db.Column(db.String(50), nullable=True)

    def __init__(self, name, city, addr, pin, phone_number="", major=""):
        self.name = name
        self.city = city
        self.addr = addr
        self.pin = pin
        self.phone_number = phone_number
        self.major = major

@app.route('/')
def show_all():
    return render_template(
        'show_all.html',
        students=Students.query.all(),
        show_major=major_enabled()
    )

@app.route('/new', methods=['GET', 'POST'])
def new():
    if request.method == 'POST':
        if not request.form['name'] or not request.form['city'] or not request.form['addr']:
            flash('Please enter all the fields', 'error')
        else:
            major_val = request.form.get('major', '') if major_enabled() else None
            student = Students(
                request.form['name'],
                request.form['city'],
                request.form['addr'],
                request.form['pin'],
                request.form.get('phone_number', ''),
                major=major_val
            )
            db.session.add(student)
            db.session.commit()
            flash('Record was successfully added')
            return redirect(url_for('show_all'))
    return render_template('new.html', show_major=major_enabled())

with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True)
