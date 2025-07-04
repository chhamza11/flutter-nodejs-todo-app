// index.js

require('dotenv').config(); // ✅ must be first

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

const Todo = require('./models/Todo');

const app = express();
const PORT = process.env.PORT || 3000;

// Debugging
console.log("🔍 MONGO_URI from .env:", process.env.MONGO_URI);

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log("✅ MongoDB connected");
}).catch((err) => {
  console.error("❌ MongoDB connection error:", err);
});

// ➕ Add a new todo
app.post('/todos', async (req, res) => {
  try {
    const { title } = req.body;
    const newTodo = new Todo({ title });
    await newTodo.save();
    res.status(201).json(newTodo);
  } catch (err) {
    res.status(500).json({ message: 'Error creating todo', error: err });
  }
});

// 📥 Get all todos
app.get('/todos', async (req, res) => {
  try {
    console.log("Type of Todo:", typeof Todo);
    console.log("Todo keys:", Object.keys(Todo));

    const todos = await Todo.find();
    res.json(todos);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching todos', error: err });
  }
});

// ✅ Toggle complete
app.patch('/todos/:id/complete', async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);
    if (!todo) return res.status(404).json({ message: 'Todo not found' });
    todo.isCompleted = !todo.isCompleted;
    await todo.save();
    res.json(todo);
  } catch (err) {
    res.status(500).json({ message: 'Error updating todo', error: err });
  }
});

// 🗑️ Mark as deleted
app.patch('/todos/:id/delete', async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);
    if (!todo) return res.status(404).json({ message: 'Todo not found' });
    todo.isDeleted = true;
    await todo.save();
    res.json(todo);
  } catch (err) {
    res.status(500).json({ message: 'Error deleting todo', error: err });
  }
});

// ♻️ Restore from deleted
app.patch('/todos/:id/restore', async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);
    if (!todo) return res.status(404).json({ message: 'Todo not found' });
    todo.isDeleted = false;
    await todo.save();
    res.json(todo);
  } catch (err) {
    res.status(500).json({ message: 'Error restoring todo', error: err });
  }
});

// ❌ Permanently delete
app.delete('/todos/:id', async (req, res) => {
  try {
    const todo = await Todo.findByIdAndDelete(req.params.id);
    if (!todo) return res.status(404).json({ message: 'Todo not found' });
    res.json({ message: 'Todo permanently deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting todo', error: err });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
});
