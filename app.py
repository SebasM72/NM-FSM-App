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

class Students(db.Model):
    id = db.Column('student_id', db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    city = db.Column(db.String(50))
    addr = db.Column(db.String(200))
    pin = db.Column(db.String(10))
    phone_number = db.Column(db.String(20))

    def __init__(self, name, city, addr, pin, phone_number=""):
        self.name = name
        self.city = city
        self.addr = addr
        self.pin = pin
        self.phone_number = phone_number

@app.route('/')
def show_all():
    return render_template('show_all.html', students=Students.query.all())

@app.route('/new', methods=['GET', 'POST'])
def new():
    if request.method == 'POST':
        if not request.form['name'] or not request.form['city'] or not request.form['addr']:
            flash('Please enter all the fields', 'error')
        else:
            student = Students(
                request.form['name'],
                request.form['city'],
                request.form['addr'],
                request.form['pin'],
                request.form.get('phone_number', '')
            )
            db.session.add(student)
            db.session.commit()
            flash('Record was successfully added')
            return redirect(url_for('show_all'))
    return render_template('new.html')

with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True)
