import streamlit as st
from google.cloud import firestore

db = firestore.Client.from_service_account_json("serviceAccountKey.json")

st.title("🛡️ Sentinel Dashboard")

# 1. Sidebar Filter
view_option = st.sidebar.radio("View Filter", ["Online Only", "All Discovered Hosts"])

miners_ref = db.collection("miners")
docs = miners_ref.stream()

for doc in docs:
    data = doc.to_dict()
    status = data.get("status", "Offline")
    
    # 2. Filtering Logic
    if view_option == "Online Only" and status == "Offline":
        continue

    with st.container(border=True):
        col1, col2 = st.columns([3, 1])
        with col1:
            st.write(f"**Host:** {doc.id}")
            if status == "Online":
                st.success(f"Hashrate: {data['hashrate']:.2f} H/s")
            else:
                st.error("Offline")
        with col2:
            st.metric("CPU", f"{data.get('cpu_usage', 'N/A')}%")
