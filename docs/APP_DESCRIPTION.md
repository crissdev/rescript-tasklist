# Task List

Manage work and track progress via tasks. Visualize tasks with the help of boards.

## Features

The application provides a three column view called board. Each column represents a status the tasks can be in. As it progresses, the task usually moves from left to right. Each status must be unique. No two columns can share the same status.

The columns supported by the application are: To Do, In Progress, Done.

The user can change a task status by moving it from one column to another via drag-and-drop or by editing the task and changing its status.

The application provides a default board with a three-column view. This is the only board displayed by the application.

A board should display the tasks as small cards with as little information as possible (title). The board should also have the ability to display larger cards with 2-3 rows of text from the description. The two card styles can be named normal/default and relaxed. The user shoud have a way to choose between these two styles.

A board must have a name so the user can easily identify it.

The user can create a new task by providing a title and a description. A new task starts with the todo status.

The user can delete a task. Once deleted, the task is removed from the board.

Tasks are saved in the browser's local storage, so they are preserved when the page is reloaded.


## Model

A task has the following attributes:
- id
- title
- description
- created_date
- status          (todo, in-progress, done)
- modified_date

A task moves from todo -> in-progress -> done.


## Out of scope

- Authentication or authorization checks
- Track who creates or changes the status of the task
- Keep a history of the task as it moves from one status to another
- Rich text description (markdown or HTML)
- Attachments of any kind (images, docs etc.) to tasks
- Time zone support with automatic translation in the UI
- Internationalization or localization
- Defining custom boards and configuring what columns to be displayed
- Have multiple boards open/visible at a time
- Choose between available boards and select one to be displayed. The user would pick one of the available boards, identified by its name, and display it instead of the default board.
- Adding columns to a board. The user would add more columns beyond To Do, In Progress and Done, each with its own unique status.
- Defining a custom task status
