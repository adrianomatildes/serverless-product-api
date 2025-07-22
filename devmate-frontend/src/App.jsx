// src/App.jsx
import React, { useEffect, useState } from 'react'
import ProductForm from './components/ProductForm'
import ProductList from './components/ProductList'

export default function App() {
  const [produtos, setProdutos] = useState([])

  const carregarProdutos = async () => {
    try {
      // API URL
      const response = await fetch('https://4sq6828dsh.execute-api.us-east-1.amazonaws.com/dev/produtos')
      if (!response.ok) throw new Error('Erro ao buscar produtos')
      const data = await response.json()
      setProdutos(data)
    } catch (error) {
      console.error('Erro ao carregar produtos:', error)
    }
  }

  useEffect(() => {
    carregarProdutos()
  }, [])

  return (
    <div className="container" style={{ padding: '2rem' }}>
      <h1>DevMate - Cadastro de Produtos</h1>
      <ProductForm onProdutoCadastrado={carregarProdutos} />
      <hr style={{ margin: '2rem 0' }} />
      <ProductList produtos={produtos} />
    </div>
  )
}