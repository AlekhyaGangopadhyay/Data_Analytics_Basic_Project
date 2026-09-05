# DBMS and ER Modeling — Enhanced Lecture Notes
### Unit: Introduction to Database Systems and Entity-Relationship Model

**Syllabus coverage:** Concept & Overview of DBMS, Data Models [2L] • Database Languages, DBA, Database Users, Three-Schema Architecture [2L] • E-R Modelling — Basic Concepts, Design Issues, Mapping Constraints [2L] • Keys, ER Diagram [2L] • Weak Entity Sets, Extended ER Features [2L]

This document expands the original syllabus notes with worked examples, comparison tables, "tricky question" traps commonly seen in exams, and a comprehensive question bank (short answer, long answer, and viva-style) at the end of every section.

---

## LECTURE 1–2: Concept & Overview of DBMS, Data Models

### 1.1 Why Databases? The File-Processing Problem

Before DBMSs, organizations stored data in flat files managed directly by each application. Imagine a university with three separate applications: **Registrar**, **Library**, and **Hostel**, each keeping its own file of student records.

**Problems this creates (with concrete examples):**

| Problem | Example |
|---|---|
| **Data Redundancy** | A student's name and address are stored separately in Registrar's file, Library's file, and Hostel's file. |
| **Data Inconsistency** | The student updates their address with the Registrar but not the Library — now two "truths" exist. |
| **Poor Data Isolation** | Data is scattered across files in different formats; writing a new application to cross-reference "which library defaulters also owe hostel fees" is painful. |
| **Integrity Problems** | Constraints like "GPA must be between 0 and 10" are buried inside each application's code, not enforced centrally — easy to bypass or forget. |
| **Atomicity Problems** | If a bank transfer program crashes after debiting one account but before crediting another, the file system has no built-in recovery. |
| **Concurrent Access Anomalies** | Two clerks simultaneously updating the same seat-booking file can overwrite each other's changes (lost update problem). |
| **Security Problems** | Hard to restrict "only the Accounts clerk can see salary data" when every application has raw file access. |

> **Definition — Data:** Known facts that can be recorded and that have an implicit meaning (e.g., a student's name, a roll number).
>
> **Definition — Database:** A collection of related data, organized to model an aspect of the real world, designed and populated with data for a specific purpose.
>
> **Definition — Mini-world / Universe of Discourse (UoD):** The portion of the real world reflected in the database — e.g., for a UNIVERSITY database, the mini-world is students, courses, instructors, and grades — *not* the university's sports teams or catering budget.
>
> **Definition — DBMS:** A collection of programs that enables users to create and maintain a database — i.e., it supports defining, constructing, manipulating, and sharing databases among users and applications.
>
> **Definition — Database System:** DBMS software + the database itself + (often included) the associated application programs. The complete package.

**Tricky distinction:** *Database* vs. *DBMS* vs. *Database System* — students often conflate these.
- Database = the data.
- DBMS = the software that manages the data.
- Database System = DBMS + Database + Applications together.

### 1.2 The Database Approach: Three Defining Characteristics

1. **Self-Describing Nature (Catalog/Metadata):** The DBMS catalog stores **metadata** — the description of the database structure (tables, columns, types, constraints) — separately from the data itself. This is what gives DBMS software its **generality**: the same DBMS engine (e.g., MySQL) can run a banking application or a hospital application, because it reads the catalog to know what the data looks like, rather than having that knowledge hard-coded.
2. **Program-Data Independence (Insulation):** Because structure is described in metadata rather than embedded in application code, we can change the storage structure (e.g., add a column, change an index) without rewriting every access program. Contrast this with file-processing systems, where the file structure is hard-coded into each program (**program-data dependence**).
3. **Data Abstraction:** The DBMS provides a **conceptual (logical) view**, hiding storage details. Users manipulate high-level constructs (tables, rows) without knowing about B-trees, disk blocks, or file pointers.

**Bonus characteristics often asked in exams:**
- **Support of multiple views of the data** — different user groups see only what's relevant to them (an External Schema/view).
- **Sharing of data and multi-user transaction processing** — concurrency control (e.g., locking) ensures simultaneous users don't corrupt data; recovery mechanisms restore consistent states after crashes.

### 1.3 When to *Avoid* a DBMS (The Cost of Generality)

A DBMS is not "always the answer." It brings **overhead**: cost of software/hardware, and processing overhead for generality, security, concurrency control, backup, and recovery.

**Avoid a DBMS when:**
- Database and applications are **simple, well-defined, and not expected to change**.
- There are **stringent real-time requirements** that a DBMS's overhead cannot satisfy (e.g., some embedded/real-time control systems).
- **No multiple-user access is required** — a single user with simple needs may be fine with a spreadsheet or flat file.
- **Cost of a DBMS licence/hardware cannot be justified** for a very small, throwaway application.

> **Tricky exam trap:** Students often write "DBMS is always better than file systems." The correct nuanced answer acknowledges DBMS overhead and lists scenarios where a file system is *still* the rational choice.

### 1.4 Data Models

> **Definition — Data Model:** A collection of concepts that can be used to describe the structure of a database — the data types, relationships, and constraints — and usually also a set of basic **operations** for retrieving and updating the data.

**Categories of data models (by abstraction level):**

| Category | Description | Example |
|---|---|---|
| **High-level / Conceptual** | Close to how users perceive data; entity-based | ER Model, EER Model |
| **Representational / Implementation** | Understandable by end users but close to how data is organized in storage | Relational Model, Network Model, Hierarchical Model |
| **Low-level / Physical** | Describes how data is stored as bits/bytes, access paths, indexes | Physical storage models |

**Data Model Operations:**
- **Basic/generic operations:** insert, delete, update — built into the data model itself.
- **User-defined operations:** operations specific to the application, e.g., `compute_student_gpa()`, `update_inventory()` — these are typically implemented via stored procedures or application code, not part of the base model.

### 1.5 Schema vs. Instance (Intension vs. Extension)

This is one of the **most frequently tested distinctions** in this unit.

| | Database Schema | Database State (Instance) |
|---|---|---|
| **Also called** | Intension | Extension, "snapshot" |
| **What it is** | The description/blueprint — structure, data types, constraints | The actual data stored at a particular moment |
| **How often it changes** | Rarely (only during schema evolution) | Continuously (every insert/delete/update) |
| **Example** | COURSE has attributes (Course_number, Course_name, Credit_hours, Department) | The row: `CS3380 | Database Systems | 3 | CS` |

**Analogy:** Schema = the architectural blueprint of a house. State = the furniture arrangement inside the house right now. The blueprint rarely changes; furniture moves daily.

- **Valid State:** A database state that satisfies the structure and constraints specified in the schema.
- **Initial State:** The state of the database when it is first populated.
- Every state after that is a valid state as long as constraints are respected (this is **state constraint enforcement**).

> **Tricky question:** "If a company renames a column from `Salary` to `Basic_Pay`, is this a change to the schema or the state?" → **Schema**, because it alters the structure/description, not just the data values.

### 1.6 Quick Recap Table

| Concept | One-line definition |
|---|---|
| Data | Recorded facts with implicit meaning |
| Database | Collection of related data |
| DBMS | Software to define/construct/maintain a database |
| Database System | DBMS + Database + Applications |
| Metadata | Data about data, stored in the catalog |
| Mini-world | The real-world slice being modeled |
| Schema | The structural description (intension) |
| State | The current data snapshot (extension) |

### 1.7 Question Bank — Lecture 1–2

**Short Answer:**
1. Define DBMS and differentiate it from a Database System.
2. List and explain the three main characteristics of the database approach.
3. What is metadata? Why is it essential for the "generality" of a DBMS?
4. Differentiate between Database Schema and Database State with an example.
5. Give two scenarios where using a DBMS would NOT be advisable.
6. What is program-data independence, and how does it differ from the older file-processing paradigm?

**Long Answer / Essay:**
1. "The database approach solves problems that plague traditional file processing systems." Discuss this statement with at least four concrete problems of file processing and how the database approach resolves each.
2. Explain the concept of data abstraction. How does it help insulate application programs from changes in physical storage?
3. Critically analyze the trade-offs (cost vs. benefit) an organization must weigh before adopting a DBMS.

**Tricky / Conceptual Traps:**
1. *True or False:* "A database always requires a DBMS to exist." (Answer: False — a database is just organized data; in principle it could exist without DBMS software, though in practice the two are almost always paired. Distinguish carefully: the *Database System* requires the DBMS, but "database" as a term only refers to the data.)
2. Why can't we say a spreadsheet application is a "DBMS" even though it stores and retrieves data? (Because it lacks generality, catalog-driven metadata, concurrent multi-user transaction support, and formal constraint enforcement.)
3. Explain why "self-describing" and "program-data independence" are related but distinct properties.

---

## LECTURE 2 (contd.): Database Languages, DBA, Database Users, Three-Schema Architecture

### 2.1 The Three-Schema Architecture

Proposed to achieve and visualize **data independence**, this architecture separates the *user applications* from the *physical database*.

| Level | Describes | Model Used | Audience |
|---|---|---|---|
| **External Level** | Individual user views — each showing only relevant part of the DB | Any view/subschema model | Specific user groups (e.g., a payroll clerk sees only salary-related attributes) |
| **Conceptual Level** | The *entire* database's structure and constraints, community-wide | Implementation-level model (e.g., relational) | DBA / whole organization |
| **Internal Level** | Physical storage structures, access paths, indexes | Physical data model | Storage engineers |

**Diagram (textual):**

```
 [External View 1] [External View 2] [External View 3]
        \               |                /
         \              |               /
              CONCEPTUAL SCHEMA  <-- entire logical structure
                      |
              INTERNAL SCHEMA    <-- physical storage & indexes
                      |
               Stored Database
```

### 2.2 Data Independence — The Payoff of Three Schemas

> **Definition:** The capacity to change the schema at one level without having to change the schema at the next higher level.

| Type | What can change | What stays the same |
|---|---|---|
| **Logical Data Independence** | Conceptual schema (e.g., add a new entity type, add an attribute) | External schemas / application programs (mostly unaffected, unless they directly reference the removed item) |
| **Physical Data Independence** | Internal schema (e.g., switch from a heap file to a B-tree index, move to new storage media) | Conceptual schema (unaffected) |

**Mechanism:** The DBMS maintains **mappings** between levels. A request at the external level is mapped to the conceptual level, then mapped further down to the internal level for physical execution. Change the internal schema → update only the *conceptual/internal mapping*. Applications remain untouched.

**Worked Example:** Suppose the DBA decides to add an index on the `Student.Email` column to speed up searches. This is a change to the **internal schema**. Because of physical data independence, the conceptual schema (which says `STUDENT` has attributes `Name, Roll_no, Email, ...`) doesn't change, and none of the application programs need to be rewritten.

> **Logical data independence is considered "harder to achieve"** than physical, because conceptual schema changes (e.g., splitting one entity into two) can genuinely break external views/programs that reference the old structure directly.

### 2.3 Database Languages

| Language | Full Form | Used By | Purpose |
|---|---|---|---|
| **DDL** | Data Definition Language | DBA / Designer | Defines the conceptual (and sometimes internal) schema — e.g., `CREATE TABLE` |
| **SDL** | Storage Definition Language | DBA | Specifies the internal schema (storage structures) — often merged into DDL in modern relational DBMSs |
| **VDL** | View Definition Language | DBA / Designer | Specifies user views / external schemas — e.g., `CREATE VIEW` |
| **DML** | Data Manipulation Language | All users | Retrieval, insertion, deletion, modification of data |

**DML further splits into:**

| Type | Description | Example |
|---|---|---|
| **High-level / Non-procedural / Declarative DML** | User specifies *what* data is needed, not *how* to get it. Can be used interactively or embedded in a program. Often **set-at-a-time** (retrieves many records in one statement). | SQL |
| **Low-level / Procedural DML** | User specifies *how* to obtain data, often record-at-a-time, requiring loops/iteration (e.g., using cursors). | Embedded SQL with cursors, older network/hierarchical DML |

> **Tricky nuance:** SQL is called non-procedural, but embedded SQL inside a host language (e.g., C or Java) commonly uses **cursors** to iterate row-by-row — a semi-procedural usage. Exams sometimes ask you to identify that SQL itself is declarative even when *used* procedurally within an application.

**Other terms sometimes tested:**
- **DCL (Data Control Language):** grants/revokes permissions — `GRANT`, `REVOKE` (not in the original notes but commonly clubbed with DDL/DML in exams).
- **TCL (Transaction Control Language):** `COMMIT`, `ROLLBACK`.

### 2.4 The Database Administrator (DBA) and Database Designer

| Role | Responsibilities |
|---|---|
| **DBA** | Authorizing access to the database; coordinating and monitoring its use; acquiring software/hardware resources; overall administrative responsibility, resolving security/performance issues, arbitrating conflicting requirements. |
| **Database Designer** | Identifies the data to be stored; chooses appropriate structures to represent this data; communicates with **all** prospective users to understand their requirements and design a schema that satisfies the needs of the entire community of users (not just one department). |

> **Tricky distinction:** The DBA manages an *existing, running* system (security, tuning, backup). The Database Designer works largely at the *design/modeling stage* (translating mini-world requirements into ER/relational schemas). A single person may play both roles in a small organization, but conceptually they are distinct.

### 2.5 Classification of Database End-Users

| Category | Characteristics | Example |
|---|---|---|
| **Casual End-Users** | Access DB occasionally; need different information each time; use sophisticated query languages | A manager who queries sales figures once a month |
| **Naive / Parametric End-Users** | Constantly query and update the DB using standard, "canned" transactions | Bank tellers, reservation clerks, data-entry clerks |
| **Sophisticated End-Users** | Engineers, scientists, business analysts who thoroughly understand DBMS facilities to implement complex applications; may use software packages that work closely with the stored data | Data scientists running analytical queries |
| **Stand-Alone Users** | Maintain personal databases using ready-made program packages providing easy menu/graphics interfaces | A person using tax-filing software, an address-book app |

**Also often tested — Categories of System/DBMS Personnel (not end-users but "actors on the scene"):**
- **System Analysts & Application Programmers** (Software Engineers): design/implement application programs. Application programmers using **rapid application development (RAD)** tools.
- **DBMS System Designers and Implementers:** design/implement the DBMS modules/interfaces as software packages (these are the vendors, e.g., Oracle/MySQL engineers) — distinct from the DBA of a specific installation.
- **Tool Developers:** design and implement tools (performance monitors, report generators, etc.).
- **Operators and Maintenance Personnel ("Workers Behind the Scene"):** responsible for the actual running and maintenance of hardware/software.

> **Tricky question:** "Is a data scientist a 'casual' or 'sophisticated' end-user?" → **Sophisticated**, because they use complex analytical tools and understand the system deeply, even though their access frequency might resemble a casual user's. The key differentiator is *depth of understanding and tool usage*, not frequency.

### 2.6 Question Bank — Lecture 2

**Short Answer:**
1. Draw and label the Three-Schema Architecture.
2. Differentiate between logical and physical data independence.
3. What is the difference between DDL and DML? Give one example of each.
4. List any three responsibilities of a DBA.
5. Give an example each for casual, naive, and sophisticated end-users.

**Long Answer:**
1. Explain how the Three-Schema Architecture achieves data independence. Use a concrete example of a schema change at each level and describe its ripple effect (or lack thereof).
2. Compare and contrast procedural and non-procedural DML with examples.
3. Discuss the various categories of database end-users and personnel, explaining how their needs differ.

**Tricky / Conceptual Traps:**
1. "If we change the conceptual schema, does the internal schema also need to change?" → Not necessarily directly, but the mapping *does* need updating; and logical data independence tries to shield *external* schemas, not internal ones, from conceptual changes.
2. Why is physical data independence considered "easier" to achieve than logical data independence? (Storage-level changes rarely affect the conceptual meaning of data, whereas conceptual changes like removing an attribute can directly break dependent views.)
3. Is SQL purely non-procedural? Justify with the cursor example.

---

## LECTURE 3–4: E-R Modelling — Basic Concepts, Design Issues, Mapping Constraints

### 3.1 Why ER Modeling?

The **Entity-Relationship (ER) model** is a high-level **conceptual data model** developed to facilitate database design by allowing specification of an enterprise's requirements — resulting in a detailed, easy-to-understand ER diagram that can later be mapped into a relational schema. **ER is for the data/structural side; UML is for the software/behavioral side** — a distinction the original notes emphasize as a "verdict," and one worth remembering as an exam one-liner.

### 3.2 Entities and Attributes

> **Entity:** A "thing" in the real world with an independent existence — an object that can be distinctly identified (e.g., a specific employee, a specific car).
>
> **Entity Type:** Defines a *collection* (set) of entities that have the same attributes (e.g., `STUDENT` is an entity type).
>
> **Entity Set:** The collection of all entities of a particular entity type in the database at a given moment (e.g., all current student records) — this is the "state"/"extension" of the entity type.

**Tricky distinction:** Entity Type = definition (like a class); Entity Set = instances (like objects) — mirrors the Schema vs. State distinction from Section 1.5.

#### Attribute Taxonomy (with examples)

| Type | Description | Example | ERD Notation |
|---|---|---|---|
| **Simple / Atomic** | Cannot be divided further | `Sex`, `Ssn` | Single oval |
| **Composite** | Can be divided into smaller sub-parts, each with independent meaning | `Address` → `{Street, City, State, Zip}`; `Name` → `{First_name, Middle_name, Last_name}` | Oval with sub-ovals branching off |
| **Multi-valued** | An entity can have multiple values for the same attribute | `Color` of a car (a car can be two-tone); `Phone_number` (a person can have several) | Double oval or `{Color}` |
| **Derived** | A value calculated/derived from other attribute(s), not stored directly | `Age` derived from `Birth_date`; `Years_employed` derived from `Hire_date` | Dashed oval |
| **Stored** | An attribute directly stored (as opposed to derived) | `Birth_date` itself | Regular oval |
| **Key Attribute** | Uniquely identifies each entity | `Ssn` for `EMPLOYEE` | Underlined |
| **Null-valued** | An attribute with no applicable/known value for an entity | `Apartment_number` for someone living in a house | — |

**Composite of Multi-valued (nested) example:** An employee's `Address_phone` could be a multi-valued composite attribute: each employee can have several addresses, and each address itself is composite `{Street, City, State}` paired with a phone.

> **Tricky question:** "Is `Age` a simple or derived attribute?" → **Derived**, since it can be computed from `Birth_date` and the current date; storing both `Age` and `Birth_date` risks **update anomalies** (Age becomes stale unless continuously recalculated).

### 3.3 Relationships and Relationship Types

> **Relationship instance:** An association between two (or more) entities, e.g., "Employee John works_for Department Research."
>
> **Relationship type:** The set of relationships of the same type, e.g., `WORKS_FOR` relating `EMPLOYEE` to `DEPARTMENT`.
>
> **Degree of a relationship type:** The number of participating entity types.

| Degree | Name | Example |
|---|---|---|
| 1 | Unary / Recursive | `EMPLOYEE supervises EMPLOYEE` (an employee supervises another employee) |
| 2 | Binary | `EMPLOYEE works_for DEPARTMENT` |
| 3 | Ternary | `SUPPLIER supplies PART to PROJECT` |
| n | n-ary | Rare; generally decomposed into binary relationships where possible for simplicity |

**Recursive relationships need role names** to distinguish the two participations of the same entity type — e.g., in `EMPLOYEE supervises EMPLOYEE`, one participation plays the role "Supervisor" and the other plays "Supervisee."

### 3.4 Structural Constraints on Relationships

Two related but distinct constraints govern a relationship — a very common point of confusion:

#### (a) Cardinality Ratio (for binary relationships): 1:1, 1:N, N:1, M:N

| Ratio | Meaning | Example |
|---|---|---|
| **1:1** | One entity in A relates to at most one entity in B, and vice versa | `EMPLOYEE manages DEPARTMENT` (one employee manages one department; one department has one manager) |
| **1:N** | One entity in A relates to many entities in B, but each entity in B relates to only one in A | `DEPARTMENT has EMPLOYEE` (one department has many employees; each employee belongs to one department) |
| **M:N** | Entities on both sides can relate to multiple entities on the other side | `EMPLOYEE works_on PROJECT` (an employee can work on many projects; a project can have many employees) |

#### (b) Participation Constraint: Total vs. Partial

| Type | Meaning | Example |
|---|---|---|
| **Total Participation** | *Every* entity in the entity set **must** participate in at least one relationship instance (existence dependency) | Every `EMPLOYEE` must `work_for` some `DEPARTMENT` — an employee record can't exist without belonging to a department |
| **Partial Participation** | Only *some* entities need to participate | Not every `EMPLOYEE` need be a `MANAGES` a department — only a few are managers |

**Tricky combined example:** In `EMPLOYEE manages DEPARTMENT`:
- Cardinality: 1:1
- Participation of `DEPARTMENT` in `MANAGES`: **Total** (every department must have a manager)
- Participation of `EMPLOYEE` in `MANAGES`: **Partial** (most employees are not managers)

#### (c) The (min, max) Notation — "The Looking-Away Principle"

Instead of separately specifying cardinality ratio and participation, we can specify a pair **(min, max)** on the edge connecting an entity type to a relationship, where:
- `min` = minimum number of relationship instances each entity must participate in (0 = partial, 1+ = total)
- `max` = maximum number of relationship instances each entity can participate in (1 = "one," N = "many")

> **"Looking-away" principle (as emphasized in the original notes):** The (min, max) constraint written *next to Entity A's edge* describes Entity A's participation — you determine it by looking at how many times entities of A can/must appear associated with instances of the relationship, which conceptually corresponds to "looking away" from A, across the relationship, toward the *other* entity, to count how many *of the other entity's* partners a single A-instance requires.

**Worked example (EMPLOYEE works_for DEPARTMENT, 1:N, total participation of EMPLOYEE):**
- On the edge from `EMPLOYEE` to `WORKS_FOR`: (1, 1) — every employee works for exactly one department.
- On the edge from `DEPARTMENT` to `WORKS_FOR`: (0, N) — a department can have zero (newly formed) to many employees. If every department must have at least one employee, this becomes (1, N).

> **Tricky question often mis-answered:** "Does the (min,max) on the EMPLOYEE side describe how many employees a department has, or how many departments an employee works for?" → It describes **how many departments an employee works for** (since it sits on Employee's edge) — students frequently flip this backward. The number sitting next to an entity describes *that entity's own participation count* in the relationship, not the count of the other side.

### 3.5 ER Design Issues (Common Pitfalls)

1. **Choosing between Entity type vs. Attribute:** Should "Department" be an attribute of `EMPLOYEE`, or its own entity type? Rule of thumb: if the "attribute" has its own attributes (e.g., Department has a `Manager`, `Location`, `Budget`), or participates in relationships with other entities, it should be an **entity type**, not just an attribute.
2. **Choosing between Entity type vs. Relationship type:** Sometimes a concept can be modeled either way — e.g., is "Marriage" an attribute, a relationship between two `PERSON` entities, or its own entity (if it has attributes like `Marriage_date`, `Location`)? If the association itself needs attributes, model it as a relationship (or even a full entity for M:N ternary complexities).
3. **Choosing the degree of a relationship:** Avoid unnecessary ternary relationships when the same fact can be captured with binary relationships, *unless* the ternary relationship carries meaning that can't be decomposed (e.g., `SUPPLIER-PART-PROJECT` supply quantities genuinely depend on all three together).
4. **Placement of relationship attributes:** In an M:N relationship, attributes describing the relationship itself (e.g., `Hours` in `WORKS_ON`) must be attached to the relationship, not to either entity, because the value depends on the *combination* of both entities.

### 3.6 Question Bank — Lecture 3–4

**Short Answer:**
1. Differentiate between Entity Type and Entity Set.
2. Give one example each of a simple, composite, multi-valued, and derived attribute.
3. What is the degree of a relationship? Give an example of a ternary relationship.
4. Differentiate between cardinality ratio and participation constraint.
5. Explain the (min, max) notation with a small example.

**Long Answer:**
1. Using the EMPLOYEE-DEPARTMENT-PROJECT mini-world, identify at least 3 entity types, 2 relationship types (with cardinality ratios), and classify at least 4 attributes by type.
2. Discuss the key design issues faced while constructing an ER diagram, with an example of a case where an entity vs. attribute decision must be made.
3. Explain recursive (unary) relationships with an example, and explain why role names are necessary.

**Tricky / Conceptual Traps:**
1. "A `WORKS_ON` relationship between EMPLOYEE and PROJECT has an attribute `Hours`. Should `Hours` be an attribute of EMPLOYEE, PROJECT, or the relationship itself?" → The **relationship**, since the number of hours depends on the specific employee-project pairing, not on either entity alone.
2. "Total participation always corresponds to (1,1) in the min-max notation." → **False.** Total participation only requires min ≥ 1; max could still be N (e.g., (1,N)).
3. Why can converting a ternary relationship into three binary relationships sometimes lose information? (Because a ternary fact like "Supplier S supplies Part P to Project J in quantity Q" cannot always be reconstructed correctly from three separate pairwise facts.)

---

## LECTURE 4 (contd.): Keys and the Entity-Relationship Diagram

### 4.1 The Complete Key Hierarchy

| Key Type | Definition | Example |
|---|---|---|
| **Superkey** | Any set of one or more attributes whose combined values uniquely identify each entity — may contain extra, non-essential attributes | `{Ssn}`, `{Ssn, Name}`, `{Ssn, Address}` |
| **Candidate Key** | A *minimal* superkey — remove any attribute and uniqueness is lost | `{Ssn}` (assuming Ssn alone is unique) |
| **Primary Key** | The candidate key chosen by the designer as the *principal* means of identifying entities; underlined in ERDs | `Ssn` chosen over `Email` as PK for EMPLOYEE |
| **Alternate Key(s)** | Candidate key(s) *not* chosen as the primary key | If both `Ssn` and `Email` uniquely identify EMPLOYEE, and `Ssn` is PK, then `Email` is an alternate key |
| **Foreign Key** | An attribute (or set) in one relation that refers to the primary key of another (possibly the same) relation — the "relational bridge" | `Course_number` in SECTION referencing COURSE's PK |
| **Partial Key (Discriminator)** | For weak entities — distinguishes entities *within* the scope of one owner, but not globally unique alone | `Dependent_name` distinguishes dependents *of one employee*, not across all employees |

**Worked Example:**
Consider `STUDENT (Roll_no, Ssn, Name, Email, Phone)` where `Roll_no`, `Ssn`, and `Email` are each individually unique.
- Superkeys: `{Roll_no}`, `{Ssn}`, `{Email}`, `{Roll_no, Name}`, `{Ssn, Phone}`, etc. (any superset of a candidate key)
- Candidate Keys: `{Roll_no}`, `{Ssn}`, `{Email}` (each minimal and unique)
- Primary Key: `Roll_no` (designer's choice)
- Alternate Keys: `Ssn`, `Email`

> **Tricky question:** "Is every candidate key also a superkey?" → **Yes**, always — a candidate key is simply a *minimal* superkey. But not every superkey is a candidate key (superkeys can have redundant attributes).
>
> **Tricky question:** "Can a primary key have NULL values?" → **No.** Entity integrity requires that no primary key attribute (or component of a composite PK) can be null.

### 4.2 ER Diagram (ERD) — Complete Notation Legend

| Symbol | Meaning |
|---|---|
| **Rectangle** | Entity Type |
| **Double Rectangle** | Weak Entity Type |
| **Diamond** | Relationship Type |
| **Double Diamond** | Identifying Relationship Type |
| **Oval** | Attribute |
| **Double Oval** | Multi-valued Attribute |
| **Dashed Oval** | Derived Attribute |
| **Underlined text (in oval)** | Primary Key Attribute |
| **Dashed underline** | Partial Key (Discriminator) of a weak entity |
| **Line** | Connects entity to attribute, or entity to relationship |
| **(min, max) on a line** | Structural constraint (participation + cardinality combined) |

### 4.3 Sample Worked ERD Scenario

**Mini-world:** A COMPANY has DEPARTMENTs; each department has many EMPLOYEEs; an employee may have many DEPENDENTs; employees WORK_ON multiple PROJECTs with hours logged.

- `DEPARTMENT (Dept_name (PK), Dept_number, Location {multi-valued})`
- `EMPLOYEE (Ssn (PK), Name (composite: First, Middle, Last), Birth_date, Age (derived))`
- `WORKS_FOR`: relationship between EMPLOYEE and DEPARTMENT, cardinality **N:1** (many employees, one department), total participation of EMPLOYEE.
- `MANAGES`: relationship between EMPLOYEE and DEPARTMENT, cardinality **1:1**, total participation of DEPARTMENT, partial participation of EMPLOYEE.
- `WORKS_ON`: relationship between EMPLOYEE and PROJECT, cardinality **M:N**, with relationship attribute `Hours`.
- `DEPENDENT`: a **weak entity**, identified by partial key `Dependent_name` + owner `EMPLOYEE`'s primary key `Ssn`, via identifying relationship `DEPENDENTS_OF`.

### 4.4 Question Bank — Lecture 4 (Keys & ERD)

**Short Answer:**
1. Differentiate between Superkey, Candidate Key, and Primary Key with an example.
2. What is a Foreign Key? Why is it called the "relational bridge"?
3. List the ERD notation for: Weak Entity, Multi-valued Attribute, Derived Attribute, Identifying Relationship.
4. Can a table have more than one candidate key? Can it have more than one primary key?

**Long Answer:**
1. For a relation `BOOK (ISBN, Title, Author_ssn, Publisher_id, Edition)` where `ISBN` and `{Title, Edition}` are both unique combinations, identify all superkeys, candidate keys, and justify your choice of primary key.
2. Draw (describe in words) a complete ERD legend and explain each symbol with one example from a UNIVERSITY database.

**Tricky / Conceptual Traps:**
1. "A composite primary key is a primary key made of two or more attributes together; can a subset of that composite key be a foreign key elsewhere?" → Yes, this is common (e.g., in a weak entity's composite PK, the owner's PK portion is simultaneously a foreign key).
2. "If Ssn uniquely identifies an employee, is {Ssn, Name} a candidate key?" → **No** — it's a superkey but *not* candidate, since it isn't minimal (Name is redundant for uniqueness).
3. Why must primary keys be NOT NULL but foreign keys are sometimes allowed to be NULL? (A FK being null just means "no relationship for this instance yet" — e.g., a new employee not yet assigned a department — whereas a null PK would break entity identification entirely.)

---

## LECTURE 5–6: Weak Entity Sets and Extended ER (EER) Features

### 5.1 Weak Entities — The Identification Chain

> **Definition — Weak Entity Type:** An entity type that does **not** have sufficient attributes to form a primary key on its own. It must be identified by combining:
> 1. Its own **partial key (discriminator)** — unique only *within* the scope of one owner.
> 2. The **primary key of its owner (identifying/strong) entity**.
> via an **identifying relationship** (shown as a double diamond, connecting to a double-rectangle weak entity).

**Classic Example:** `DEPENDENT` of an `EMPLOYEE`.
- `DEPENDENT` has attributes like `Dependent_name`, `Birth_date`, `Relationship` (e.g., "Son", "Spouse") — but `Dependent_name` alone isn't globally unique (two different employees could each have a dependent named "Sam").
- The **actual primary key of DEPENDENT** = `{Employee_ssn (owner's PK), Dependent_name (partial key)}`.
- Without the `EMPLOYEE`, the `DEPENDENT` record has no independent existence — this is **existence dependency**, and its participation in the identifying relationship is always **total**.

**Other classic examples of weak entities:**
- `ROOM` weak on `HOTEL` (Room_number alone repeats across hotels).
- `TRANSACTION` weak on `BANK_ACCOUNT` (Transaction_id might only be unique per account).
- `SECTION` weak on `COURSE` in some schemas (Section_number repeats across courses).

> **Tricky question:** "Can a weak entity be weak on another weak entity?" → In principle, **multi-level weak entity chains are possible** (a weak entity's owner is itself weak on a further owner), though this is uncommon and can usually be avoided by good design. The identification chain must eventually terminate at a strong (owner) entity.
>
> **Tricky question:** "Does a weak entity ever have partial participation in its identifying relationship?" → **No.** By definition, a weak entity is *existence-dependent* on its owner, so participation is always **total**.

### 5.2 Extended Entity-Relationship (EER) Model — Motivation

As mini-worlds grow more complex (CAD/CAM, telecommunications, scientific/genome databases, GIS), the basic ER model's flat entity types become insufficient. EER adds:

1. **Subclasses and Superclasses**
2. **Specialization and Generalization**
3. **Categories (Union types)**
4. **Attribute and Relationship Inheritance**

### 5.3 Superclass / Subclass

> **Superclass:** An entity type whose entities are grouped, categorized into subclasses that share common characteristics, while also possibly having unique attributes of their own.
>
> **Subclass:** A subgrouping of entities within a superclass that is meaningful to the application — has all the attributes of the superclass **plus** its own additional attributes/relationships.

**Example:** `EMPLOYEE` (superclass) with subclasses `SECRETARY`, `ENGINEER`, `TECHNICIAN`.
- All subclasses inherit `Ssn`, `Name`, `Birth_date` from `EMPLOYEE`.
- `SECRETARY` additionally has `Typing_speed`.
- `ENGINEER` additionally has `Eng_type` (e.g., Civil, Electrical).
- `TECHNICIAN` additionally has `TGrade`.

**ER notation:** A circle with a line to the superclass and subclasses branching below, often labeled with **d** (disjoint) or **o** (overlapping).

### 5.4 Specialization vs. Generalization

| | Specialization | Generalization |
|---|---|---|
| **Direction** | Top-down | Bottom-up |
| **Process** | Start with a superclass; identify distinguishing subgroups based on some distinguishing characteristic | Start with several entity types recognized as having common attributes; synthesize/combine them into a common superclass |
| **Example** | Start with `EMPLOYEE`, define `SECRETARY`, `ENGINEER` as specializations based on job role | Start with `CAR` and `TRUCK` (each with their own attributes); notice both are `VEHICLE`s and generalize into a `VEHICLE` superclass |
| **Trigger** | Application requires distinguishing among sub-groups with extra attributes/relationships | Application already has similar entity types and wants to reduce redundancy by abstracting shared attributes upward |

> **Tricky exam trap:** Specialization and Generalization are **the same result** (a superclass/subclass hierarchy) but reached via **opposite thought processes**. Exams love to ask "is this specialization or generalization?" based on the *narrative* given (did we start broad and narrow down, or start narrow and broaden up?).

### 5.5 Constraints on Specialization/Generalization

Two independent constraints, often tested in combination:

#### (a) Disjointness Constraint

| Type | Meaning | Example |
|---|---|---|
| **Disjoint (d)** | An entity can belong to **at most one** subclass | An `EMPLOYEE` is either a `SECRETARY` **or** an `ENGINEER`, never both |
| **Overlapping (o)** | An entity **can** belong to more than one subclass simultaneously | A `PERSON` can be both a `STUDENT` and an `EMPLOYEE` at the same time (a working student) |

#### (b) Completeness (Participation) Constraint

| Type | Meaning | Example |
|---|---|---|
| **Total Specialization** | Every entity in the superclass **must** belong to at least one subclass (double line in ERD) | Every `VEHICLE` must be either a `CAR` or a `TRUCK` |
| **Partial Specialization** | Entities in the superclass **may or may not** belong to any subclass (single line in ERD) | Not every `EMPLOYEE` needs to be a `SECRETARY`, `ENGINEER`, or `TECHNICIAN` — some may just be general staff |

**Combined example:** `{d, total}` VEHICLE → {CAR, TRUCK} means every vehicle is exactly one of car or truck, never both, never neither.

### 5.6 Attribute and Relationship Inheritance

> A subclass entity inherits **all** attributes of the superclass, as well as **all** relationship participations the superclass has with other entity types, in addition to its own subclass-specific attributes/relationships.

**Example:** If `EMPLOYEE` participates in `WORKS_FOR` (relates to `DEPARTMENT`), then `ENGINEER` (a subclass of `EMPLOYEE`) *automatically* also participates in `WORKS_FOR` — no need to redraw this relationship for the subclass.

> **Tricky question:** "Does a subclass inherit only attributes, or also relationships?" → **Both.** This is a commonly missed point — students often forget relationship inheritance and only remember attribute inheritance.

### 5.7 Categories (Union Types)

> **Definition:** A subclass that represents a collection of objects from **distinct** superclasses — modeling a **union** rather than a simple subset. Denoted with a circled `U`.

**Example:** `OWNER` is a category representing the union of `PERSON`, `BANK`, or `COMPANY` — because a vehicle's registered owner could be any one of these distinct entity types, unlike a normal subclass which is a subset of a *single* superclass.

**Distinction from a normal subclass:** A regular subclass (e.g., `ENGINEER`) is a subset of *one* superclass (`EMPLOYEE`). A **category** is drawn from the *union of multiple, unrelated* superclasses — it doesn't inherit from all of them simultaneously like a subclass would; rather, each `OWNER` instance derives from exactly one of `PERSON`, `BANK`, or `COMPANY`.

### 5.8 Constraints Recap Table (Weak Entities + EER)

| Concept | Key Rule |
|---|---|
| Weak entity | No independent PK; identified via owner's PK + partial key |
| Weak entity participation | Always total in the identifying relationship |
| Specialization | Top-down process |
| Generalization | Bottom-up process |
| Disjoint | Entity in at most one subclass |
| Overlapping | Entity can be in multiple subclasses |
| Total specialization | Every superclass entity must be in some subclass |
| Partial specialization | Superclass entities may belong to no subclass |
| Category (Union) | Subclass of multiple distinct superclasses |

### 5.9 Question Bank — Lecture 5–6

**Short Answer:**
1. Define a weak entity type. Why can't it have its own primary key?
2. What is a partial key/discriminator? Give an example.
3. Differentiate between specialization and generalization.
4. Differentiate between disjoint and overlapping constraints with examples.
5. What is a category (union type) in EER? How does it differ from a normal subclass?

**Long Answer:**
1. Model a `DEPENDENT` weak entity for an `EMPLOYEE` strong entity. Specify its partial key, the identifying relationship, and explain why its participation must be total.
2. For a `VEHICLE` superclass with subclasses `CAR` and `TRUCK`, explain (with constraint notation) what it would mean for this specialization to be: (a) disjoint & total, (b) overlapping & partial. Give a real-world scenario for each.
3. Explain attribute and relationship inheritance in EER with a worked example involving at least 2 levels of subclassing (e.g., EMPLOYEE → ENGINEER → SENIOR_ENGINEER).

**Tricky / Conceptual Traps:**
1. "A weak entity's partial key can sometimes look unique across the entire database by coincidence, but is it still called a 'partial key'?" → **Yes** — the classification depends on the *logical guarantee* of uniqueness (scoped to the owner), not on incidental global uniqueness in the current data snapshot.
2. "Can a subclass have its own subclasses?" → **Yes** — this creates a **specialization/generalization lattice or hierarchy** (e.g., EMPLOYEE → ENGINEER → SENIOR_ENGINEER), and inheritance cascades down every level.
3. "If EMPLOYEE → {SECRETARY, ENGINEER, TECHNICIAN} is disjoint, can an employee who is neither be a valid EMPLOYEE record?" → Depends on whether the specialization is **total or partial** — disjointness only restricts *how many* subclasses an entity can be in (at most one), not *whether* it must be in one at all.

---

## Master Comparison Tables (Cross-Cutting — High-Yield for Exams)

### A. DBMS vs. File System

| Aspect | File Processing System | DBMS |
|---|---|---|
| Redundancy | High | Controlled/minimized |
| Data Independence | None (hard-coded) | Provided (logical + physical) |
| Data Sharing | Difficult | Built-in, multi-user |
| Integrity Constraints | Application-enforced | DBMS-enforced centrally |
| Security | Weak, per-file | Centralized, fine-grained |
| Backup/Recovery | Manual, ad-hoc | Automated, transaction-based |
| Cost | Low | Higher (software, hardware, admin) |

### B. Cardinality Ratio vs. Participation Constraint

| Aspect | Cardinality Ratio | Participation Constraint |
|---|---|---|
| Answers the question | "How many?" (max number of relationship instances) | "Must it?" (is participation mandatory or optional) |
| Values | 1:1, 1:N, M:N | Total / Partial |
| Notation | Written near the relationship diamond edges (1, N, M) | Single line (partial) or double line (total) |

### C. Specialization vs. Subclass/Superclass vs. Category

| Aspect | Specialization/Generalization | Subclass/Superclass (structural result) | Category |
|---|---|---|---|
| What it is | The *process* (top-down or bottom-up) | The *resulting hierarchy* | A subclass of a **union** of distinct superclasses |
| Number of superclasses | One | One | Multiple (unrelated) |
| Inheritance | From the one superclass | From the one superclass | From whichever single superclass the instance actually came from |

### D. Weak Entity vs. Strong Entity

| Aspect | Strong Entity | Weak Entity |
|---|---|---|
| Own Primary Key | Yes | No (needs partial key + owner's PK) |
| Existence | Independent | Dependent on owner |
| ERD Notation | Single rectangle | Double rectangle |
| Participation in identifying relationship | N/A | Always total |

---

## Final High-Value "Tricky Question" Round-Up

1. **Q:** Is every relationship type necessarily binary?
 **A:** No — relationships can be unary (recursive), binary, ternary, or n-ary; binary is just the most common.

2. **Q:** Can an attribute be both multi-valued and composite?
 **A:** Yes — e.g., `Address_phone` where each employee can have multiple addresses, and each address is itself composite (Street, City, etc.).

3. **Q:** Does physical data independence mean the conceptual schema *never* changes?
 **A:** No — physical data independence only shields the conceptual schema from *internal/storage-level* changes; the conceptual schema can still change due to evolving mini-world requirements (which is a logical data independence concern for the *external* level).

4. **Q:** Is the DBA the same as the Database Designer?
 **A:** Not necessarily — the DBA manages the live system (security, performance, resources); the Designer works largely during the modeling/design phase, communicating with users to define the schema. One person can wear both hats in small teams, but the roles are conceptually distinct.

5. **Q:** In a 1:1 relationship, must both participations be total?
 **A:** No — cardinality (1:1) and participation (total/partial) are independent; a 1:1 relationship can have total participation on one side and partial on the other (e.g., EMPLOYEE manages DEPARTMENT: total for DEPARTMENT, partial for EMPLOYEE).

6. **Q:** Does a foreign key have to reference a *different* table?
 **A:** No — a foreign key can be a **self-referencing** (recursive) reference to the same table's primary key, e.g., `Supervisor_ssn` in `EMPLOYEE` referencing `EMPLOYEE.Ssn`.

7. **Q:** Are all candidate keys shown as "underlined" in an ERD?
 **A:** No — by convention, only the chosen **primary key** is underlined in the ERD; alternate (unchosen) candidate keys are typically not underlined, though some notations use dashed underlines for them.

8. **Q:** Can a weak entity type have more than one identifying (owner) entity type?
 **A:** Generally no in the classical model — a weak entity has exactly one identifying owner entity type per identifying relationship, though it may have additional non-identifying relationships to other entities.

---

*End of enhanced notes. Recommended next step: attempt the full ERD for a "HOSPITAL" or "AIRLINE RESERVATION" mini-world as practice, applying every concept above (entities, attributes, cardinality, participation, keys, weak entities, and at least one specialization hierarchy).*
