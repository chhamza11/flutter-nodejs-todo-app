const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

let todos = [];

// Get all todos
app.get('/todos', (req, res) => {
  res.json(todos);
});

// Add a new todo
app.post('/todos', (req, res) => {
  const { title } = req.body;
  const newTodo = {
    id: Date.now(),
    title,
    isCompleted: false,
    isDeleted: false,
  };
  todos.push(newTodo);
  res.status(201).json(newTodo);
});

// Mark as completed/uncompleted
app.patch('/todos/:id/complete', (req, res) => {
  const { id } = req.params;
  const todo = todos.find(t => t.id === Number(id));
  if (todo) {
    todo.isCompleted = !todo.isCompleted;
    res.json(todo);
  } else {
    res.status(404).json({ message: 'Todo not found' });
  }
});

// Move to deleted
app.patch('/todos/:id/delete', (req, res) => {
  const { id } = req.params;
  const todo = todos.find(t => t.id === Number(id));
  if (todo) {
    todo.isDeleted = true;
    res.json(todo);
  } else {
    res.status(404).json({ message: 'Todo not found' });
  }
});

// Restore from deleted
app.patch('/todos/:id/restore', (req, res) => {
  const { id } = req.params;
  const todo = todos.find(t => t.id === Number(id));
  if (todo) {
    todo.isDeleted = false;
    res.json(todo);
  } else {
    res.status(404).json({ message: 'Todo not found' });
  }
});

// Permanently delete
app.delete('/todos/:id', (req, res) => {
  const { id } = req.params;
  const index = todos.findIndex(t => t.id === Number(id));
  if (index !== -1) {
    todos.splice(index, 1);
    res.json({ message: 'Todo permanently deleted' });
  } else {
    res.status(404).json({ message: 'Todo not found' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});