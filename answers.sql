-- Library Management System Database

-- Create database
CREATE DATABASE library_management;

-- Use the database
USE library_management;

-- Table: Branches
-- Stores information about different library branches
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    opening_hours VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Categories
-- Stores book categories/genres
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Publishers
-- Stores information about book publishers
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Authors
-- Stores information about book authors
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_author_name (last_name, first_name)
);

-- Table: Books
-- Stores information about books (metadata)
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    publication_date DATE,
    isbn VARCHAR(20) UNIQUE,
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    INDEX idx_book_title (title)
);

-- Table: Book_Authors (Many-to-Many relationship between Books and Authors)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role VARCHAR(50) DEFAULT 'Author', -- Could be Author, Co-Author, Editor, etc.
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Table: Book_Categories (Many-to-Many relationship between Books and Categories)
CREATE TABLE book_categories (
    book_id INT,
    category_id INT,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Table: Book_Items
-- Represents physical copies of books
CREATE TABLE book_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    barcode VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('Available', 'Checked Out', 'Reserved', 'Lost', 'Under Repair') DEFAULT 'Available',
    acquisition_date DATE NOT NULL,
    price DECIMAL(10, 2),
    `condition` ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'Good',
    shelf_location VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE RESTRICT,
    INDEX idx_status (status)
);

-- Table: Patron_Types
-- Different types of library patrons with different privileges
CREATE TABLE patron_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    loan_limit INT NOT NULL DEFAULT 5,
    loan_period INT NOT NULL DEFAULT 14, -- in days
    fine_amount DECIMAL(5, 2) DEFAULT 0.25, -- daily fine for late returns
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Patrons
-- Library users/members
CREATE TABLE patrons (
    patron_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    type_id INT NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('Active', 'Expired', 'Suspended', 'Blacklisted') DEFAULT 'Active',
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES patron_types(type_id),
    INDEX idx_patron_name (last_name, first_name),
    INDEX idx_card_number (library_card_number)
);

-- Table: Staff
-- Library employees
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    branch_id INT,
    hire_date DATE NOT NULL,
    status ENUM('Active', 'On Leave', 'Terminated') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE SET NULL,
    INDEX idx_staff_name (last_name, first_name)
);

-- Table: Loans
-- Track book borrowing
CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    patron_id INT NOT NULL,
    checkout_staff_id INT,
    checkin_staff_id INT,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATETIME,
    renewal_count INT DEFAULT 0,
    status ENUM('Checked Out', 'Returned', 'Overdue', 'Lost') DEFAULT 'Checked Out',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES book_items(item_id),
    FOREIGN KEY (patron_id) REFERENCES patrons(patron_id),
    FOREIGN KEY (checkout_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    FOREIGN KEY (checkin_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    INDEX idx_checkout_date (checkout_date),
    INDEX idx_due_date (due_date),
    INDEX idx_return_date (return_date),
    INDEX idx_status (status)
);

-- Table: Reservations
-- For book reservation system
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    patron_id INT NOT NULL,
    branch_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    fulfillment_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (patron_id) REFERENCES patrons(patron_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    INDEX idx_status_date (status, reservation_date)
);

-- Table: Fines
-- Track fines for overdue books and other violations
CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    patron_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    reason VARCHAR(100) NOT NULL,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    payment_date DATETIME,
    collected_by_staff_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL,
    FOREIGN KEY (patron_id) REFERENCES patrons(patron_id),
    FOREIGN KEY (collected_by_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    INDEX idx_status (status)
);

-- Table: Events
-- For library events and programs
CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_attendees INT,
    registration_required BOOLEAN DEFAULT FALSE,
    coordinator_staff_id INT,
    status ENUM('Scheduled', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (coordinator_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    INDEX idx_event_date (event_date)
);

-- Table: Event_Registrations
-- For tracking patron registrations for events
CREATE TABLE event_registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    patron_id INT NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No Show', 'Cancelled') DEFAULT 'Registered',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (patron_id) REFERENCES patrons(patron_id) ON DELETE CASCADE,
    UNIQUE KEY unique_event_patron (event_id, patron_id)
);

-- Table: Feedbacks
-- For collecting feedback from patrons
CREATE TABLE feedbacks (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    patron_id INT,
    branch_id INT,
    subject VARCHAR(100) NOT NULL,
    feedback_text TEXT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    feedback_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    response TEXT,
    response_staff_id INT,
    response_date DATETIME,
    status ENUM('Submitted', 'In Review', 'Responded', 'Closed') DEFAULT 'Submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patron_id) REFERENCES patrons(patron_id) ON DELETE SET NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE SET NULL,
    FOREIGN KEY (response_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Table: Acquisitions
-- Track new book purchases and donations
CREATE TABLE acquisitions (
    acquisition_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    branch_id INT NOT NULL,
    acquisition_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    acquisition_type ENUM('Purchase', 'Donation', 'Exchange') NOT NULL,
    vendor VARCHAR(100),
    order_number VARCHAR(50),
    cost DECIMAL(10, 2),
    status ENUM('Ordered', 'Received', 'Processed', 'Cancelled') DEFAULT 'Ordered',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- Table: Inventory_Checks
-- For tracking periodic inventory checks
CREATE TABLE inventory_checks (
    check_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    conducted_by_staff_id INT NOT NULL,
    status ENUM('Planned', 'In Progress', 'Completed') DEFAULT 'Planned',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (conducted_by_staff_id) REFERENCES staff(staff_id)
);

-- Table: Inventory_Check_Items
-- Details of items checked during inventory
CREATE TABLE inventory_check_items (
    check_item_id INT PRIMARY KEY AUTO_INCREMENT,
    check_id INT NOT NULL,
    item_id INT NOT NULL,
    expected_status ENUM('Available', 'Checked Out', 'Reserved', 'Lost', 'Under Repair'),
    actual_status ENUM('Available', 'Checked Out', 'Reserved', 'Lost', 'Under Repair', 'Missing'),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (check_id) REFERENCES inventory_checks(check_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES book_items(item_id)
);