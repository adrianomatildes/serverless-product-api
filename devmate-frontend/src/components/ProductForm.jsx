// src/components/ProductForm.jsx
import React, { useState } from 'react'

export default function ProductForm({ onProdutoCadastrado }) {
  const [form, setForm] = useState({ nome: '', preco: '', imagem: null })

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm({ ...form, [name]: value })
  }

  const handleImageChange = (e) => {
    const file = e.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onloadend = () => {
        setForm((prev) => ({ ...prev, imagem: reader.result }))
      }
      reader.readAsDataURL(file)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    try {
      // API URL
      const response = await fetch('https://4sq6828dsh.execute-api.us-east-1.amazonaws.com/dev/produtos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form)
      })

      if (!response.ok) throw new Error('Erro ao cadastrar o produto')

      alert('Produto cadastrado com sucesso!')
      setForm({ nome: '', preco: '', imagem: null })
      onProdutoCadastrado()
    } catch (error) {
      console.error(error)
      alert('Erro ao cadastrar o produto')
    }
  }

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: '2rem' }}>
      <div>
        <label>Nome:</label>
        <input type="text" name="nome" value={form.nome} onChange={handleChange} required />
      </div>
      <div>
        <label>Preço:</label>
        <input type="number" name="preco" value={form.preco} onChange={handleChange} required />
      </div>
      <div>
        <label>Imagem:</label>
        <input type="file" accept="image/*" onChange={handleImageChange} />
      </div>
      <button type="submit">Cadastrar</button>
    </form>
  )
}