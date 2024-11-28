import psycopg2
from datebase import datebase

conn = psycopg2.connect(
    dbname="your_database_name",  
    user="your_username",        
    password="your_password",    
    host="your_host",            
    port="your_port"              
)

cursor = conn.cursor()

def create_tables():
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT
    )''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS news (
        id SERIAL PRIMARY KEY,
        category_id INT,
        title VARCHAR(200) NOT NULL,
        content TEXT NOT NULL,
        published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_published BOOLEAN DEFAULT FALSE,
        views INTEGER DEFAULT 0,
        FOREIGN KEY(category_id) REFERENCES categories(id)
    )''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        news_id INT,
        author_name VARCHAR(100),
        comment_text TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(news_id) REFERENCES news(id)
    )''')

    conn.commit()

def alter_tables():
    cursor.execute('''
    ALTER TABLE news ADD COLUMN views INTEGER DEFAULT 0;
    ''')

    cursor.execute('''
    ALTER TABLE comments ALTER COLUMN author_name TYPE TEXT;
    ''')

    conn.commit()

def add_data():
    # Kategoriyalar
    cursor.execute("INSERT INTO categories (name, description) VALUES (%s, %s)", ('Technology', 'Tech related news'))
    cursor.execute("INSERT INTO categories (name, description) VALUES (%s, %s)", ('Sports', 'Sports news'))
    cursor.execute("INSERT INTO categories (name, description) VALUES (%s, %s)", ('Health', 'Health related news'))

    # Yangiliklar
    cursor.execute("INSERT INTO news (category_id, title, content) VALUES (%s, %s, %s)", (1, 'Tech News 1', 'Content of tech news 1'))
    cursor.execute("INSERT INTO news (category_id, title, content) VALUES (%s, %s, %s)", (2, 'Sports News 1', 'Content of sports news 1'))
    cursor.execute("INSERT INTO news (category_id, title, content) VALUES (%s, %s, %s)", (3, 'Health News 1', 'Content of health news 1'))

    # Sharhlar
    cursor.execute("INSERT INTO comments (news_id, author_name, comment_text) VALUES (%s, %s, %s)", (1, 'John', 'Great article on tech!'))
    cursor.execute("INSERT INTO comments (news_id, author_name, comment_text) VALUES (%s, %s, %s)", (2, 'Alice', 'Amazing sports news!'))
    cursor.execute("INSERT INTO comments (news_id, author_name, comment_text) VALUES (%s, %s, %s)", (3, 'Bob', 'Helpful health tips!'))

    conn.commit()

def update_data():
    cursor.execute("UPDATE news SET views = views + 1")
    cursor.execute("UPDATE news SET is_published = TRUE WHERE published_at < CURRENT_TIMESTAMP - INTERVAL '1 day'")
    conn.commit()

def delete_data():
    cursor.execute("DELETE FROM comments WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year'")
    conn.commit()

def select_data():
    cursor.execute('''
    SELECT n.id AS news_id, n.title, c.name AS category_name
    FROM news n
    JOIN categories c ON n.category_id = c.id
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"News ID: {row[0]}, Title: {row[1]}, Category: {row[2]}")

    cursor.execute('''
    SELECT * FROM news n
    JOIN categories c ON n.category_id = c.id
    WHERE c.name = 'Technology'
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Title: {row[2]}, Content: {row[3]}")

    cursor.execute('''
    SELECT * FROM news WHERE is_published = TRUE ORDER BY published_at DESC LIMIT 5
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Title: {row[2]}, Published At: {row[4]}")

    cursor.execute('''
    SELECT * FROM news WHERE views BETWEEN 10 AND 100
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Title: {row[2]}, Views: {row[6]}")

    cursor.execute('''
    SELECT * FROM comments WHERE author_name LIKE 'A%'
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Author: {row[2]}, Comment: {row[3]}")

    cursor.execute('''
    SELECT * FROM comments WHERE author_name IS NULL OR author_name = ''
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Author: {row[2]}, Comment: {row[3]}")

    cursor.execute('''
    SELECT c.name, COUNT(n.id)
    FROM categories c
    LEFT JOIN news n ON c.id = n.category_id
    GROUP BY c.name
    ''')
    rows = cursor.fetchall()
    for row in rows:
        print(f"Category: {row[0]}, News Count: {row[1]}")

def add_constraints():
    cursor.execute('''
    ALTER TABLE news ADD CONSTRAINT unique_title UNIQUE (title);
    ''')
    conn.commit()

def main():
    create_tables()
    add_data()
    alter_tables()
    update_data()
    delete_data()
    select_data()
    add_constraints()

if __name__ == "__main__":
    main()
