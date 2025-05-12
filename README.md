
# Library Management System Database

A comprehensive relational database solution designed to manage all aspects of a modern library's operations.

## Project Overview

This Library Management System Database provides a robust foundation for managing library resources, patrons, and daily operations. It's designed to streamline book management, lending processes, patron interactions, and administrative tasks.

### Key Features

- **Complete Book Management**: Track books, authors, publishers, and physical book items
- **Patron Management**: Manage library members, membership types, and privileges
- **Circulation Management**: Handle loans, returns, reservations, and fines
- **Branch Operations**: Support for multiple library branches
- **Event Management**: Organize and track library events and registrations
- **Administrative Tools**: Acquisition tracking, inventory management, and feedback collection

## Entity Relationship Diagram (ERD)

Below is a textual representation of the database structure. For a visual ERD, please import the SQL file into a database modeling tool like MySQL Workbench, dbdiagram.io, or Lucidchart.

```
branches (1) ----< book_items (M)
books (1) ----< book_items (M)
books (M) ----< book_authors >---- (M) authors
books (M) ----< book_categories >---- (M) categories
publishers (1) ----< books (M)
patron_types (1) ----< patrons (M)
branches (1) ----< staff (M)
book_items (1) ----< loans (M)
patrons (1) ----< loans (M)
staff (1) ----< loans (M) [checkout_staff_id]
staff (1) ----< loans (M) [checkin_staff_id]
books (1) ----< reservations (M)
patrons (1) ----< reservations (M)
branches (1) ----< reservations (M)
loans (1) ----< fines (M)
patrons (1) ----< fines (M)
staff (1) ----< fines (M) [collected_by_staff_id]
branches (1) ----< events (M)
staff (1) ----< events (M) [coordinator_staff_id]
events (M) ----< event_registrations >---- (M) patrons
patrons (1) ----< feedbacks (M)
branches (1) ----< feedbacks (M)
staff (1) ----< feedbacks (M) [response_staff_id]
books (1) ----< acquisitions (M)
branches (1) ----< acquisitions (M)
branches (1) ----< inventory_checks (M)
staff (1) ----< inventory_checks (M) [conducted_by_staff_id]
inventory_checks (1) ----< inventory_check_items (M)
book_items (1) ----< inventory_check_items (M)
```

## Setup Instructions

### Prerequisites
- MySQL Server 5.7+ 
- MySQL Workbench (for visualization)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/zippyrehema123/library-management-system.git
   cd library-management-system
   ```

2. **Import the database**
   
    using MySQL Workbench:
   - Open MySQL Workbench
   - Navigate to Server > Data Import
   - Choose "Import from Self-Contained File" and select the library_management-system.sql file
   - Start the import process

3. **Verify installation**
   ```sql
   USE library_management;
   SHOW TABLES;
   ```
   You should see all 19 tables listed.

## Database Structure

The database consists of 19 tables:

1. **branches** - Library branch locations
2. **categories** - Book genres and categories
3. **publishers** - Book publishers
4. **authors** - Book authors
5. **books** - Book metadata
6. **book_authors** - Many-to-many relationship between books and authors
7. **book_categories** - Many-to-many relationship between books and categories
8. **book_items** - Physical copies of books
9. **patron_types** - Different types of library memberships
10. **patrons** - Library members
11. **staff** - Library employees
12. **loans** - Book borrowing records
13. **reservations** - Book reservation system
14. **fines** - Fines for late returns and violations
15. **events** - Library events and programs
16. **event_registrations** - Patron registrations for events
17. **feedbacks** - Patron feedback collection
18. **acquisitions** - Book acquisition tracking
19. **inventory_checks** and **inventory_check_items** - Inventory management

## Usage Examples

### Basic Queries

1. Find all available books at a specific branch:
   ```sql
   SELECT b.title, bi.barcode, bi.shelf_location
   FROM books b
   JOIN book_items bi ON b.book_id = bi.book_id
   WHERE bi.branch_id = 1 AND bi.status = 'Available'
   ORDER BY b.title;
   ```

2. Check out a book to a patron:
   ```sql
   -- First, update book_items status
   UPDATE book_items SET status = 'Checked Out' WHERE item_id = 123;
   
   -- Then, create loan record
   INSERT INTO loans (item_id, patron_id, checkout_staff_id, due_date)
   VALUES (123, 456, 789, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY));
   ```

3. Find overdue books:
   ```sql
   SELECT p.first_name, p.last_name, p.email, b.title, l.due_date,
     DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
   FROM loans l
   JOIN patrons p ON l.patron_id = p.patron_id
   JOIN book_items bi ON l.item_id = bi.item_id
   JOIN books b ON bi.book_id = b.book_id
   WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE
   ORDER BY days_overdue DESC;
   ```

