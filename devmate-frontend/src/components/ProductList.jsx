// src/components/ProductList.jsx
import React from 'react'
import './ProductList.css'

export default function ProductList({ produtos }) {
  return (
    <div>
      <h2>Produtos Cadastrados</h2>
      {produtos.length === 0 ? (
        <p>Nenhum produto cadastrado.</p>
      ) : (
        <div className="product-grid">
          {produtos.map((prod, index) => (
            <div className="product-card" key={index}>
              <h3>{prod.nome}</h3>
              <p><strong>Preço:</strong> R$ {prod.preco}</p>
              {prod.imagem && (
                <img src={prod.imagem} alt={prod.nome} style={{ maxWidth: '100%', maxHeight: '120px', marginTop: '0.5rem' }} />
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}